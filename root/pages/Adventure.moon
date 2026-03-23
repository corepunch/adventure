ui = require "orca.UIKit"
games = require "config.games"
import Games from require "model.games"

require 'zilscript'
server = require 'zilscript.runtime'

font = "chronicle/fonts/Times New Roman"

-- Common ZIL files shared across all games (loaded before game-specific files)
common = {
  "zork1/globals.zil",
  "zork1/clock.zil",
  "zork1/parser.zil",
  "zork1/verbs.zil",
  "zork1/syntax.zil",
}

-- Pre-initialize all game environments at module level so that ZIL compilation
-- runs during Orca's loading screen, not after it (which would cause a black
-- screen freeze before the first frame is shown).
game_envs = {}
for gameId, config in pairs games
  env = server.create_game_env()
  assert server.init(env), "Failed to initialize environment for " .. gameId
  assert server.load_zil_files(common, env, {save_lua: false}), "Failed to load common ZIL files for " .. gameId
  assert server.load_zil_files(config.modules, env, {save_lua: false}), "Failed to load modules for " .. gameId
  game_envs[gameId] = env

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

Outgoing = (line) ->
	-- p class: "m-2 text-lg text-neutral-8", fontFamily: font, line
	bubble = p class: "mx-4 my-1 px-4 py-2 text-xl text-neutral-8 bg-neutral-3 align-right", fontFamily: font, line
	bubble.BorderRadius = 12
	bubble.BorderBottomRightRadius = 0
	return bubble

Incoming = (line) ->
	bubble = p class: "p-2 text-xl text-neutral-8", fontFamily: font, line
	return bubble

class Controls extends ui.StackView
	new: (@game, @console) => super!
	class: "flex-col w-full h-full overflow-y-scroll"
	body: =>
		action = 'm-1 py-1 px-2 text-blue-300 bg-neutral-4 hover:bg-primary hover:text-blue-100'
		perform = (button) ->
			input = "#{button.verb} #{button.object or ''}"
			input = input\gsub '-', ' ' -- replace dashes with spaces for better parsing
			@console\addChild Outgoing input\lower!
			scene = @game\resume input
			print("Game response:", scene, button)
			for line in scene\gmatch "[^\n]+" do
				@console\addChild Incoming line
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

class ChatInput extends ui.Node2D
	new: (@game, @console, @gameRecordId) => super!
	class: "gap-2 bg-neutral-3"
	body: =>
		submit = (cmd) -> 
			@console\addChild Outgoing cmd.Text
			Games\addCommand @gameRecordId, cmd.Text
			scene = @game\resume cmd.Text
			for line in scene\gmatch "[^\n]+" do
				@console\addChild Incoming line
			cmd.Text = ""
		ui.Input class: "text-lg text-middle bg-neutral-4 hover:bg-neutral-4/95 m-2 p-2 rounded-4", placeholderText: "Print command", onSubmit: submit
		
class Adventure extends ui.Node2D
	new: (@params) => 
		super!

		@config = games[@params.game]
		assert(@config, "Game not found: " .. @params.game)

		env = game_envs[@params.game]
		assert(env, "Game environment not found: " .. @params.game)

		@game = server.create_game(env)

		if @params.record
			record = Games\find @params.record
			assert(record, "Game record not found: " .. @params.record)
			math.randomseed record.seed
			@gameRecordId = record.id
			@history = {}
			table.insert @history, {cmd: nil, output: @game\resume nil}
			for _, cmd in ipairs(record.commands or {}) do
				table.insert @history, {cmd: cmd, output: @game\resume cmd}
		else
			@gameRecordId = Games\create @params.game

	title: "Adventure"
	body: =>
		console, @controls = nil, nil
		-- img class: "w-full h-full", image: "assets/images/room-1", stretch: "UniformToFill", opacity: 0.33
		grid rows: "32px 48px auto 64px 24px", ->
			ui.Node2D class: 'bg-neutral-3 w-full h-full'
			stack class: "w-full h-full bg-neutral-3 p-2 gap-2 text-xl items-center", ->
				img 
					class: "inline-block align-middle text-neutral-9", 
					image: "assets/icons/back.svg?width=48&type=Mask", 
					onLeftMouseUp: => @navigate "/"
					-- p class: "inline-block align-middle text-green-300", "Dungeons & Dragons"
				p class: "text-neutral-9 text-xl text-nowrap", @config.title
				-- ui.Button class: "py-1 px-3 font-bold bg-button hover:bg-button-hover text-dark-1", text: "Button"
				-- ui.Button class: "py-1 px-3 font-bold bg-button hover:bg-button-hover text-dark-1", text: "Button"
			console = stack "#console", class: 'flex-col overflow-y-scroll h-full py-4', ->
				if @history
					for _, entry in ipairs @history do
						if entry.cmd
							Outgoing entry.cmd
						for line in entry.output\gmatch "[^\n]+" do
							Incoming line
				else
					scene = @game\resume @input
					for line in scene\gmatch "[^\n]+" do
						-- if line == '>' then continue
						Incoming line
			console.onScrollHeightChanged = () => @setScrollTop @ScrollHeight
			@controls = ChatInput @game, console, @gameRecordId
			-- controls = Controls @game, console
			ui.Node2D class: 'bg-neutral-3 w-full h-full'
