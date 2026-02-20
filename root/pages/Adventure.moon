ui = require "orca.ui"
appwrite = require "appwrite.functions"
openai = require "openai"
json = require "orca.parsers.json"
games = require "config.games"

require 'zilscript'
server = require 'zilscript.runtime'

system = "You are the Dungeon Master in a text-based Dungeons & Dragons adventure. Describe scenes vividly, present choices naturally, and react dynamically to player actions. Keep descriptions immersive but concise."
user = "Let's begin a new D&D adventure. Describe what my character sees as I awaken in a mysterious forest clearing, and ask me what I want to do next."

font = "adventure/fonts/Times New Roman"
common = {
  "zork1/globals.zil",
	"zork1/clock.zil",
  "zork1/parser.zil",
  "zork1/verbs.zil",
  "zork1/main.zil",
  "zork1/syntax.zil",
  -- "zork1/actions.zil",
  -- "zork1/dungeon.zil",
  -- "adventure/horror.zil",
}

-- highlight = (text) ->
-- 	fmt = "<u>%s</u>"
-- 	for _, dir in ipairs(env.DESCS)
-- 		cap = dir\sub(1,1)\upper! .. dir\sub 2
-- 		text = text\gsub("(%f[%a]#{dir}%f[%A])", (m) -> fmt\format m)
-- 		text = text\gsub("(%f[%a]#{cap}%f[%A])", (m) -> fmt\format m)
-- 	for _, dir in ipairs(env.DIRS)
-- 		cap = dir\sub(1,1)\upper! .. dir\sub 2
-- 		text = text\gsub("(%f[%a]#{dir}%f[%A])", (m) -> fmt\format m)
-- 		text = text\gsub("(%f[%a]#{cap}%f[%A])", (m) -> fmt\format m)
-- 	return text

Message = (line, style) -> 
	if style
		-- p class: "m-2 text-lg #{style}", fontFamily: font, line
		bubble = p class: "mx-4 my-1 px-4 py-2 text-lg text-neutral-9 bg-neutral-3 align-right", fontFamily: font, line
		bubble.BorderRadius = 12
		bubble.BorderBottomRightRadius = 0
		return bubble
	else
		bubble = p class: "p-2 text-lg text-neutral-8", fontFamily: font, line
		return bubble

class Controls extends ui.StackView
	new: (@game, @console) => super!
	class: "flex-col w-full h-full overflow-y-scroll"
	body: =>
		action = 'm-1 py-1 px-2 text-blue-300 bg-neutral-4 hover:bg-primary hover:text-blue-100'
		perform = (button) ->
			input = "#{button.verb} #{button.object or ''}"
			input = input\gsub '-', ' ' -- replace dashes with spaces for better parsing
			@console\addChild Message input\lower!, "text-amber-200"
			scene = @game\resume input
			print("Game response:", scene, button)
			for line in scene\gmatch "[^\n]+" do
				@console\addChild Message line
			-- @rebuild!
			@rebuild!

		Item = (indent, key, verbs, children) ->
			stack class: "ml-#{indent}", ->
				p class: 'm-2 text-green-300', key
				for _, verb in ipairs verbs do
					button class: action, onClick: perform, verb: verb\lower!, object: key, verb\lower!
			for _, t in ipairs children do
				Item indent + 4, table.unpack t

		for _, t in ipairs @game\resume 'room-items' do
			Item 0, table.unpack t

		for _, t in ipairs @game\resume 'room-exits' do
			dir, room = table.unpack t
			stack class: 'flex-row items-center', ->
				button class: action, onClick: perform, verb: "walk", object: dir\lower!, dir\lower!
				p class: 'm-2 text-green-300', room

		stack class: 'flex-row items-center', ->
			button class: action, onClick: perform, verb: "inventory", "Inventory"
			button class: action, onClick: perform, verb: "look", "Look Around"

		p class: 'm-2', @game\resume "inventory"

class ChatInput extends ui.StackView
	new: (@game, @console) => super!
	class: "flex-row w-full h-full gap-2 bg-neutral-3"
	body: =>
		submit = (cmd) -> 
			@console\addChild Message cmd.Text, "text-amber-200"
			scene = @game\resume cmd.Text
			for line in scene\gmatch "[^\n]+" do
				@console\addChild Message line
			cmd.Text = ""
		d = ui.Input class: "text-lg bg-neutral-4 hover:bg-neutral-4/95 w-full h-full m-2 px-4 text-middle rounded-4", placeholderText: "Print command", onSubmit: submit
		
class Adventure extends ui.Node2D
	new: (@params) => 
		super!

		@env = server.create_game_env()
		@config = games[@params.game]	

		assert(@config, "Game not found: " .. @params.game)
		assert(server.init(@env), "Failed to initialize game environment")
		assert(server.load_zil_files(common, @env), "Failed to load common ZIL files")
		assert(server.load_zil_files(@config.modules, @env), "Failed to load game-specific ZIL files")

		@game = server.create_game(@env)

	title: "Adventure"
	body: =>
		console, @controls = nil, nil
		scene = @game\resume @input
		-- img class: "w-full h-full", image: "assets/images/room-1", stretch: "UniformToFill", opacity: 0.33
		grid rows: "32px 48px auto 64px 24px", ->
			ui.Node2D class: 'bg-neutral-3 w-full h-full'
			stack class: "w-full h-full bg-neutral-3 p-2 text-xl gap-2 items-center", ->
				img class: "inline-block align-middle mr-4 text-neutral-9", image: "assets/icons/back.svg?width=48&type=mask", onLeftMouseUp: => @navigate "/overview"
					-- p class: "inline-block align-middle text-green-300", "Dungeons & Dragons"
				-- p class: "text-neutral-9 text-xl", @config.title
				ui.Button class: "py-1 px-3 font-bold bg-button hover:bg-button-hover text-dark-1", text: "Button"
				ui.Button class: "py-1 px-3 font-bold bg-button hover:bg-button-hover text-dark-1", text: "Button"
			console = stack "#console", class: 'flex-col overflow-y-scroll py-4', ->
				for line in scene\gmatch "[^\n]+" do
					-- if line == '>' then continue
					Message line
			console.onScrollHeightChanged = () => @setScrollTop @ScrollHeight
			@controls = ChatInput @game, console
			-- controls = Controls @game, console
			ui.Node2D class: 'bg-neutral-3 w-full h-full'
