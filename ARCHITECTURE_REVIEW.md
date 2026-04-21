# Architecture Review — `corepunch/adventure`

_Written from the perspective of a modern web developer. Covers structural, component-model, and data-layer concerns. Intended to guide a refactor toward a React-inspired, declarative, data/view-separated architecture._

---

## 1. Mixing Data Fetching and Rendering

The most pervasive problem is that `body:` methods double as both data-fetching and rendering layers. There is no separation between "get the data" and "paint the screen".

### `OngoingGames.moon` — database read inside `body:`

```moonscript
body: =>
    ongoing = Games\findAll!   -- ← synchronous DB read inside render
    if #ongoing == 0
        p class: "...", "No ongoing games."
    else
        stack id: "gamelist", class: "...", ->
            for game in *ongoing
                GameEntry id: game.id, game: game
```

`body:` is re-run on every rebuild. Every rebuild re-reads the JSON file. There is no caching, no loading state, and no separation of concerns.

### `MessagesView.moon` — three model calls inside `body:`

```moonscript
body: =>
    @user = Users\auth!          -- network/auth lookup
    @chat = Chats\find @params.chat  -- network call
    for msg in *Messages\findAll @chat  -- network call
        @bubble msg
```

`body:` performs authentication, fetches a chat, and fetches all messages. It also writes `@user` and `@chat` onto `self` as side effects of rendering — the render method mutates component state.

### `Adventures.moon` — navigation logic inside a component method

```moonscript
handleGameClick: (gameId) =>
    allGames = Games\findAll!   -- DB read inside a click handler that lives on the view class
    for game in *allGames do
        if game.gameId == gameId
            ok, result = @showModal Popup text: "..."
            ...
```

The "should I show a resume-game modal?" decision and the modal display are both in the view class. In a React world this belongs in a route-level action or a custom hook.

### `Adventure.moon` constructor — full game boot inside `new:`

```moonscript
new: (@params) =>
    super!
    @env = server.create_game_env()
    assert(server.init(@env), ...)
    assert(server.load_zil_files(common, @env), ...)
    assert(server.load_zil_files(@config.modules, @env), ...)
    @game = server.create_game(@env)
    if @params.record
        record = Games\find @params.record
        math.randomseed record.seed
        for _, cmd in ipairs(record.commands or {}) do
            @game\resume cmd        -- replays every command on boot
    else
        @gameRecordId = Games\create @params.game
```

The constructor:
- creates and initialises a game runtime environment,
- loads ZIL files (the game "executable"),
- re-plays the entire command history to restore game state,
- creates a new persistent game record if one does not exist.

This is controller work. A view constructor should only receive already-loaded data as props, not perform I/O.

### `ChatLayout.moon` — data fetching in a `title:` method

```moonscript
title: =>
    chat = Chats\find @params.chat   -- network call to produce a title string
    partner = Chats\getPartner chat, Users\auth!
    title = Users\getFullName partner
```

The title method performs two network calls on every evaluation. The `Header` component inside `ChatLayout` independently makes the same two calls again in its own `body:`.

**Recommended fix (consistent across all cases):**

Route handlers (the entries in `App.moon`) should fetch data and pass it as props:

```lua
-- App.moon route handler (before mounting view)
"/games": function(self)
    local games = Games:findAll()
    return Layout(OngoingGames, { games = games })
end
```

`body:` then only renders:

```moonscript
body: =>
    if #@games == 0
        p class: "...", "No ongoing games."
    else
        stack class: "...", ->
            for game in *@games
                GameEntry game: game
```

---

## 2. WPF-Style Imperative Property Mutation ("Attached Properties")

Post-construction property mutation appears in multiple files and is the single biggest stylistic mismatch with declarative UI patterns.

### In `Adventure.moon`

```moonscript
Outgoing = (line) ->
    bubble = p class: "mx-4 my-1 px-4 py-2 ...", fontFamily: font, line
    bubble.BorderRadius = 12              -- set after construction
    bubble.BorderBottomRightRadius = 0   -- set after construction
    return bubble
```

```moonscript
console.onScrollHeightChanged = () => @SetScrollTop @ScrollHeight  -- event handler assigned post-construction
```

### In `OngoingGames.moon` and `Adventures.moon` — mutation inside `body:`

```moonscript
body: =>
    @BorderWidthBottom = 1   -- sets a property on self during render
```

This is especially confusing because `@BorderWidthBottom = 1` looks like it is configuring a border, but it runs every time `body:` is called. In a declarative model this value belongs in the class declaration or in the props passed to the constructor.

### Why this matters

- Properties set after construction are invisible to anyone reading the constructor call site.
- It prevents a future optimisation where the framework can skip re-constructing nodes whose props have not changed (a virtual-DOM diffing approach).
- It creates implicit ordering dependencies: the node must be fully constructed before the mutation is safe.

**Recommended fix:** Pass all static style values as constructor props. If the orca runtime does not yet support `BorderRadius` as a constructor prop, add that support so the call can be written as:

```moonscript
bubble = p class: "mx-4 my-1 ...", BorderRadius: 12, BorderBottomRightRadius: 0, fontFamily: font, line
```

For scroll-sync, use a supported declarative event binding rather than assigning to `node.onScrollHeightChanged` after the fact:

```moonscript
console = stack "#console", class: "...", ScrollHeightChanged: (=> @SetScrollTop @ScrollHeight), -> ...
```

---

## 3. Inconsistent Use of the orca DSL

The orca API surface is used in at least three different styles within the same codebase:

| Style | Example |
|---|---|
| `ui.*` namespace | `ui.Grid`, `ui.Node2D`, `ui.StackView`, `ui.Button`, `ui.Input`, `ui.Form` |
| Bare global functions | `div`, `stack`, `p`, `button`, `grid`, `img` |
| Class inheritance from bare globals | `class ChatInput extends div`, `class Adventure extends div` |

`Adventure.moon` alone mixes all three:

```moonscript
class Controls extends ui.StackView   -- ui.* namespace
class ChatInput extends div           -- bare global
class Adventure extends div           -- bare global
-- inside body:
ui.Input class: "...", ...            -- ui.* namespace inside bare-global class
```

There is no documented convention for when to use `ui.X` vs. the bare form. This creates confusion about what the actual primitive types are, and makes it harder to know which props are valid on which node type.

**Recommended fix:** Establish a single canonical style. If `div`, `stack`, `p`, etc. are aliases for their `ui.*` counterparts (which the code implies), remove the `ui.*` references entirely and use only the bare DSL form, or vice versa. The decision should be documented in a style guide.

---

## 4. Class Inheritance for Stateless Display Components

Every view is a MoonScript class, even trivially simple ones that hold no state and gain nothing from the class model:

```moonscript
class GameEntry extends ui.Grid       -- single-use, stateless
class Entry extends ui.Grid           -- single-use, stateless
class Header extends ui.Grid          -- stateless, no methods beyond body:
class Footer extends StackView        -- receives a callback, no state
class Settings extends ui.Node2D      -- one line: p ".align-middle-center", "Settings"
class ErrorMessage extends ui.TextBlock  -- two lines in new:
```

These classes:
- Extend a base class purely for access to DSL functions — inheritance is not used polymorphically.
- Carry no instance state between renders.
- Have `body:` as their only meaningful method.

In React terms these are all function components. The class syntax adds 3–4 lines of boilerplate for zero benefit.

**Recommended rewrite pattern (Lua functional component):**

```lua
local function GameEntry(props)
    return grid { class = "w-full p-2", Columns = "auto 48px",
        BorderWidthBottom = 1,
        stack { class = "flex-col flex-1",
            LeftButtonUp = function() navigate("/adventure/" .. props.game.gameId .. "/" .. props.game.id) end,
            p { class = "text-neutral-9 text-2xl", config.title },
            p { class = "text-lg text-neutral-6", count .. " commands played" },
        },
        img { class = "...", Source = "assets/icons/delete.svg?width=32&type=Mask",
            LeftButtonUp = function() Games:delete(props.game.id); rebuild() end,
        },
    }
end
```

Classes are only justified for components that hold mutable state between renders, e.g.:
- `Adventure` (holds game engine and history)
- `MessagesView` (holds timer and last-seen cursor)

---

## 5. Debug Artifacts Left in Production Code

Several `print` calls are left in rendering and event-handling paths:

```moonscript
-- Adventures.moon body:
print("Rendering Adventures page")

-- Adventure.moon Controls.body:
print("Game response:", scene, button)
```

Large swaths of commented-out code are present in almost every file. These are normal during development but should be removed before any production release.

---

## 6. `Games` — File-Based Persistence with No Abstraction

```moonscript
class Games
    path: "tmp/games.json"
    readAll: =>
        file = io.open @path, "r"
        ...
    saveAll: (data) =>
        os.execute "mkdir -p tmp"
        file = io.open @path, "w"
        ...
    create: (gameId) =>
        games = @readAll!       -- read whole file
        table.insert games, ...
        assert @saveAll games   -- write whole file
    addCommand: (id, command) =>
        games = @readAll!       -- read whole file again
        ...
        assert @saveAll games   -- write whole file again
```

Every mutation does a full read → mutate → full write cycle with no locking. Concurrent requests (if the runtime ever allows them) would cause data loss. There is no error recovery if a write is interrupted mid-way. The `os.execute "mkdir -p tmp"` side effect inside `saveAll` runs on every save.

While this is acceptable for a single-user local prototype, the persistence layer has no abstraction: callers know about the file path and the full-read-write cycle. Wrapping this in a proper repository interface would allow swapping to SQLite or Appwrite later without touching the view layer.

---

## 7. Module-Level Mutable State for Auth Caching

```moonscript
-- model/init.moon
context = {}   -- module-level mutable table

class Account extends Model
    auth: =>
        if context.account return context.account
        res = @getaccount!
        context.account = res\json!
        return context.account

    signout: () =>
        response = super!
        export context = {}   -- resets the global cache on signout
        return response\json!
```

`context` is a module-level table. Because Lua modules are cached after the first `require`, this is effectively a global singleton. If the runtime is ever used in a multi-tenant or test context, this cache will leak between sessions. The `export context = {}` pattern in `signout` is non-idiomatic and fragile.

**Recommended fix:** Use explicit scoping — pass an auth context as a parameter, or use a proper session/store object that is instantiated per session.

---

## 8. Routing and Layout Inconsistency

```moonscript
-- App.moon
"/": => Layout page.Adventures          -- wrapped in RootLayout
"/games": => Layout page.OngoingGames   -- wrapped in RootLayout
"/adventure/:game": => page.Adventure @params     -- NOT wrapped, raw class
"/adventure/:game/:record": => page.Adventure @params  -- NOT wrapped, raw class
```

`Adventure` is intentionally full-screen (it builds its own grid with header row), but the pattern diverges silently. A reader has to check each route handler to know whether a page has the standard chrome. The distinction should be documented or encoded in the type system (e.g. a `FullScreenPage` marker vs. `Page`).

Also note: `page.OngoingGames` is misspelled `page.goingGames` in `root/pages/init.moon`:

```moonscript
-- root/pages/init.moon
return {
    Adventure: require "root.pages.Adventure"
    Adventures: require "root.pages.Adventures"
    goingGames: require "root.pages.OngoingGames"   -- ← should be OngoingGames
    SearchPage: require "root.pages.SearchPage"
}
```

This is a latent bug: any refactor that tries `page.OngoingGames` will silently get `nil`.

---

## 9. `Controls` and `ChatInput` — View Classes That Directly Call the Game Engine

```moonscript
class Controls extends ui.StackView
    new: (@game, @console) => super!
    body: =>
        perform = (button) ->
            input = "..."
            @console\addChild Outgoing input   -- ← directly mutates a sibling node
            scene = @game\resume input         -- ← calls game engine synchronously
            for line in scene\gmatch "[^\n]+" do
                @console\addChild Incoming line  -- ← directly mutates sibling again
            @rebuild!
```

`Controls` holds a reference to its sibling `console` and directly appends children to it. This is a React anti-pattern equivalent to a child component calling `document.getElementById("sibling").appendChild(...)`. The coupling prevents either component from being used independently and makes reasoning about the tree difficult.

**Recommended fix:** Lift state up. The parent (`Adventure`) should hold the message history as state. When `Controls` submits a command it dispatches an action (calls a callback prop); the parent updates its state and re-renders both the console and the controls.

---

## 10. MoonScript vs. Lua — Practical Assessment

MoonScript adds value primarily for:
- Class syntax (handled better by functional components in plain Lua)
- `=>` method shorthand (syntactic sugar, not a functional gain)
- `for x in *list` iteration (slightly cleaner than `for _, x in ipairs(list)`)
- String interpolation (`"#{value}"`)

It adds cost through:
- A compile step that produces intermediate Lua (obscures stack traces)
- `@` vs. `self.` inconsistency when reading compiled output
- `export` keyword for re-assigning upvalues (used in `model/init.moon` signout — fragile)
- Occasional MoonScript-specific gotchas (implicit returns, table constructors)

For files that become purely functional components (no class, no `@`), the migration to plain Lua is near-trivial and removes the build dependency. For the two or three genuinely stateful components (`Adventure`, `MessagesView`) it is a matter of preference.

---

## Priority Refactor Checklist

| # | File / Area | Problem | Recommended Action |
|---|---|---|---|
| 1 | `root/pages/init.moon` | `goingGames` key typo | Rename to `OngoingGames` |
| 2 | `OngoingGames.moon` | `Games\findAll!` in `body:` | Move fetch to route handler; pass `games` as prop |
| 3 | `Adventures.moon` | `Games\findAll!` in click handler; `print` in body | Extract to route-level action; remove debug print |
| 4 | `Adventure.moon` | Entire game boot in `new:`; sibling mutation in `Controls` | Extract `loadGame(params)` function; lift console state to `Adventure` |
| 5 | `Adventure.moon` | `bubble.BorderRadius = 12` post-construction mutation | Pass as constructor prop; verify orca supports it or add support |
| 6 | `Adventure.moon` | `console.onScrollHeightChanged` assigned post-construction | Use declarative event prop at construction time |
| 7 | `OngoingGames.moon`, `Adventures.moon` | `@BorderWidthBottom = 1` inside `body:` | Move to class declaration or constructor prop |
| 8 | `MessagesView.moon` | Three model calls inside `body:`; writes `@user`/`@chat` as render side-effects | Fetch in layout/route; pass as props |
| 9 | `ChatLayout.moon` | Data fetch in `title:` and `Header.body:` duplicated | Fetch once in route handler; pass to both |
| 10 | `Header.moon`, `Footer.moon`, `GameEntry`, `Entry`, `Settings`, `ErrorMessage` | Class syntax for stateless components | Convert to plain Lua functions |
| 11 | All files | Mixed `ui.*` vs. bare-global DSL usage | Pick one canonical form; document it |
| 12 | `model/init.moon` | Module-level `context` auth cache | Scope per-session; avoid `export context = {}` in signout |
| 13 | `model/init.moon` `Games` class | Full file read/write on every mutation; no abstraction | Add a proper repository interface; consider SQLite |
| 14 | All files | Large commented-out code blocks; debug `print` calls | Remove before any production milestone |

---

## Summary

The codebase is a working prototype with a clear vision, but it has grown organically with no enforced separation of concerns. From a modern web perspective, the three root problems are:

1. **No data layer / view layer boundary.** Fetching happens wherever it is needed, which is almost always inside `body:` or `new:`. Route handlers should own data loading; components should be pure render functions of their props.

2. **Imperative style in a declarative context.** Post-construction property mutation (`node.X = y`) and sibling reference passing (`@console\addChild`) are the clearest markers of this. Every property that is not a runtime event response should be passed declaratively at construction.

3. **Class ceremony for zero benefit.** A dozen single-purpose, stateless view classes that extend a base purely to access DSL helpers. Functional components remove the boilerplate and make the component boundary explicit.

Addressing these three in order — data/view separation first, declarative props second, functional components third — will make the codebase significantly easier to read, test, and extend.
