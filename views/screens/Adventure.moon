import TextBlock, StackView, ImageView, Node2D, Grid, Input from require "orca.UIKit"
import Games, Sessions from require "model"

require "zilscript"
server = require "zilscript.runtime"

use_action_buttons = false

common_zil_files = {
	"zork1/globals.zil",
	"zork1/clock.zil",
	"zork1/parser.zil",
	"zork1/verbs.zil",
	"zork1/main.zil",
	"zork1/syntax.zil",
}

AdventureSession = (game_id, requested_session_id, config) ->
	game = nil
	session_id = nil
	history = nil

	start = ->
		env = server.create_game_env!
		env.rawget = rawget
		env.rawset = rawset
		env.rawequal = rawequal
		assert server.init env
		assert server.load_zil_files common_zil_files, env
		assert server.load_zil_files config.modules, env
		game = server.create_game env

		session = if requested_session_id
			Sessions\find requested_session_id
		else
			Sessions\find_by_game_id game_id

		if session
			math.randomseed session.seed
			session_id = session.id
			history = {}
			table.insert history, { cmd: nil, output: game\resume nil }
			for _, cmd in ipairs session.commands or {} do
				table.insert history, { cmd: cmd, output: game\resume cmd }
		else
			session_id = Sessions\create game_id
			history = { { cmd: nil, output: game\resume nil } }

	entries = ->
		unless history
			history = { { cmd: nil, output: game\resume nil } }
		history

	submit = (text) ->
		text = text or ""
		text = text\gsub "[\r\n]+$", ""
		return nil if text == "" or not game
		Sessions\addCommand session_id, text
		entry = { cmd: text, output: game\resume text }
		table.insert entries!, entry
		entry

	room_items = -> game\resume("room-items") or {}
	room_exits = -> game\resume("room-exits") or {}

	actions = ->
		action_items = {
			{ label: "Look around", command: "look" }
			{ label: "Inventory", command: "inventory" }
		}

		for exit in *room_exits! do
			dir = if exit[1] then tostring exit[1] else ""
			table.insert action_items, {
				label: "Walk #{dir\lower!}"
				detail: if exit[2] then tostring exit[2] else ""
				command: "walk #{dir\lower!}"
			}

		add_item_actions = (items) ->
			for item in *items do
				name, verbs, children = table.unpack item
				for verb in *(verbs or {}) do
					table.insert action_items, {
						label: "#{verb\sub(1, 1)\upper!}#{verb\sub(2)\lower!} #{name\lower!}"
						command: "#{verb\lower!} #{name}"
					}
				add_item_actions children or {}

		add_item_actions room_items!
		action_items

	start!
	{ :entries, :submit, :room_items, :room_exits, :actions }

class Adventure extends require "orca.core.widget"
	title: "Adventure"

	content: =>
		game = Games\definition @params.game

		unless game
			@content_for "title", "Adventure"
			return @empty_state!

		@content_for "title", game.title
		@content_for "header", @make_header game.title

		session = AdventureSession @params.game, @params.session, game
		transcript = @make_transcript session
		run_command = (command) -> transcript.append session.submit command

		@content_for "footer", if use_action_buttons
			@make_action_bar session, run_command
		else
			@make_command_bar run_command

		@content_for "inner", StackView {
				class: "transcript"
				onScrollHeightChanged: => @SetScrollTop @ScrollHeight
			}, ->
				transcript.render!
				for action in *session.actions! do
					print "Action:", action.label, "->", action.command
				-- for _, item in ipairs { "Open book", "Turn on lamp", "Pick up key" }
					TextBlock { 
						class: "suggestion", 
						LeftButtonUp: -> run_command action.command 
					}, action.label

	empty_state: =>
		navigate_home = -> @navigate "/"
		StackView class: "adventure-empty", ->
			TextBlock class: "message", "No game selected"
			StackView { class: "button", LeftButtonUp: navigate_home }, ->
				TextBlock class: "label", "Back to games"

	make_header: (title) =>
		iconSize = 32
		navigate_home = -> @navigate "/"
		Grid class: "adventure-header", Columns: "#{iconSize}px 1fr", ->
			ImageView {
				class: "back-icon"
				Source: "assets/icons/back.svg?width=#{iconSize}&type=mask"
				LeftButtonUp: navigate_home
			}
			TextBlock class: "title", title

	make_transcript: (session) =>
		console_view = nil

		outgoing = (line) -> TextBlock class: "outgoing", line
		incoming = (line) -> TextBlock class: "incoming", line

		append = (entry) ->
			return unless entry and console_view
			console_view\addChild outgoing entry.cmd if entry.cmd
			for line in entry.output\gmatch "[^\n]+" do
				console_view\addChild incoming line

		render = ->
			console_view = StackView {
				class: "log"
			}, ->
				for _, entry in ipairs session.entries! do
					outgoing entry.cmd if entry.cmd
					for line in entry.output\gmatch "[^\n]+" do
						incoming line

			-- Node2D class: "transcript", =>
			-- 	@addChild console_view

		{ :append, :render }

	make_command_bar: (on_submit) =>
		StackView class: "command-bar", ->
			Input {
				class: "input"
				PlaceholderText: "Enter command..."
				Submit: (sender, evt) =>
					text = evt.Text\gsub "[\r\n]+$", ""
					return if text == ""
					sender\Clear!
					on_submit text if on_submit
					true
			}

	make_action_bar: (session, on_action) =>
		view = nil
		render_buttons = ->
			for action in *session.actions! do
				TextBlock {
					class: "chip"
					LeftButtonUp: ->
						on_action action.command
						view\rebuild render_buttons if view and view.rebuild
						true
				}, action.label

		view = StackView { class: "action-bar" }, -> render_buttons!
		view
