# Copilot Instructions

## App Structure

- Build Orca apps as MoonScript widgets first.
- Prefer widget subclasses for screens, popups, and reusable UI pieces.
- Let the layout own the chrome (`header`, `footer`, navigation shells).
- Keep data access in the model layer. Screens should call models, not reach into config or storage directly.
- If a concept needs richer behavior, turn it into a model object instead of passing raw hashes through the UI.
- Use the Streak Club structure as the reference shape:
- `app.moon` for app routing and bootstrapping.
- `model/` for data and storage logic.
- `views/layout.moon` for shared chrome.
- `views/screens/` for screen widgets.
- `views/popups/` for reusable modal widgets.
- `config/` for environment and Tailwind tokens.
- `assets/` for icons, game art, and static resources.
- Keep `root/` legacy Banking leftovers out of new work.
- Prefer direct MoonScript expressions over unnecessary locals when the value is used once.
- Example: `for game in *Games\catalog! do` is better than assigning `games = Games\catalog!` first.
- If a boolean check is just testing for nil, use the object itself directly instead of a separate `has_*` variable.

## Model Naming

- Follow the existing Lapis/Streak Club naming style for models.
- Use `find` for lookup by primary id.
- Use `find_all` for bulk lookup by ids or lists.
- Use `find_by_<field>` for a foreign-key lookup or other explicit indexed search.
- Use `url_params` on model objects that should be passed to `@url_for`.
- Prefer `find_all` for new code; keep `findAll` only when matching legacy code or an existing adapter.

## MoonScript Cheat Sheet

- `->` defines a normal function or callback.
- `=>` defines a function that needs lexical `self`.
- `\` calls a method on an object and passes the object as the first argument.
- `@name` means `self.name`.
- `@@name` means `self.__class.name`.
- `!` calls a zero-argument function, so `foo!` is `foo()`.
- Parentheses are optional for many calls, so `navigate "/games"` is fine.
- Table literals use `:` for key/value pairs.
- Indentation defines blocks.
- Favor the shortest readable form. MoonScript is used to reduce boilerplate, not to reintroduce it with extra locals.

MoonScript callback rules:
- In MoonScript, prefer `->` for callbacks.
- Use `=>` only when the callback truly needs lexical `self`.
- Most UI callbacks and nested builders should use `->`, even inside widget/layout code.
- If you only need to call helpers like `@url_for`, `@navigate`, or read locals, do not use `=>`.
- Use `=>` sparingly for cases where the callback must keep the surrounding object context across the function boundary.
- In UI trees, `->` usually means “build children here”.
- `=>` is only for places where the widget instance itself must stay bound as `self` inside the closure.

Examples:

```moon
StackView class: "bg-background", ->
	TextBlock "Hello"

Button Click: -> @navigate "/"
```

```moon
-- Only when `self` is actually needed
StackView class: "bg-background", =>
	TextBlock @title
```

Model and routing examples:

```moon
class Game
  url_params: (req, ...) =>
    "Adventure", nil, { game: @id }, ...

game = Games\definition "zork1"
@url_for game
```

```moon
class SavedGame
  @find_by_game_id: (gameId) =>
    -- return the saved run for this game
```

Tailwind and color-token rules:
- Prefer Tailwind utilities for layout, spacing, and text styling.
- Add app colors in `config/tailwind.lua` under `extend.colors`.
- Tailwind generates utilities from `--color-*` theme variables, so use names that read well as utilities. Adding `--color-mint-500` makes `bg-mint-500`, `text-mint-500`, and similar utilities available.
- Use semantic color names for UI roles: `background`, `foreground`, `surface`, `primary`, `secondary`, `muted`, `accent`, `border`, `input`, `ring`, `destructive`.
- Use `*-foreground` for text/icon color that sits on top of another token.
- Use `*-subtle` for low-emphasis surfaces or highlights.
- Use numeric scales only when you need an actual palette ramp, like `primary-500` or `gray-900`.
- Keep names consistent across light and dark themes so the same utility classes keep meaning the same thing.
- Avoid inventing many one-off color names when a semantic token already exists.

Tailwind examples:

```lua
extend = {
  colors = {
    background = "#FFFFFF",
    foreground = "#0B0F1A",
    surface = "#FFFFFF",
    ["surface-alt"] = "#F3F4F6",
    primary = "#345EC7",
    ["primary-foreground"] = "#FFFFFF",
    accent = "#345EC7",
    ["accent-foreground"] = "#FFFFFF",
    muted = "#E3E8F0",
    ["muted-foreground"] = "#6B7280",
  }
}
```

UI composition examples:

```moon
StackView class: "bg-background flex-col gap-3", ->
  TextBlock class: "text-xl font-bold text-foreground", "Choose an Adventure"
  TextBlock class: "text-sm text-muted-foreground text-wrap", "Long text should wrap inside a constrained column"
```

```moon
Grid Rows: "32px 1fr 72px", =>
  make_header title
  inner
  make_footer active_route, navigate
```
