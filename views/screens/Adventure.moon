import StackView, TextBlock, ImageView, Input from require "orca.UIKit"
Application = require "orca.core.application"

games_config = require "config.games"
import Games from require "model"
import navigate from require "chronicle/views/helpers"

require "zilscript"
server = require "zilscript.runtime"

common = {
  "zork1/globals.zil",
  "zork1/clock.zil",
  "zork1/parser.zil",
  "zork1/verbs.zil",
  "zork1/main.zil",
  "zork1/syntax.zil",
}

font = "chronicle/fonts/Times New Roman"

class Adventure extends require "orca.core.widget"
	title: "Adventure"

	content: =>
		app    = Application.current false
		data   = app and app.nav_data
		game_id   = data and data.game
		record_id = data and data.record
		config = game_id and games_config[game_id]

		unless config
			return StackView class: "bg-background flex-col p-4 gap-4 h-full justify-center", =>
				TextBlock class: "text-foreground-muted align-middle-center", "No game selected"
				StackView {
					class: "bg-surface rounded-3 px-4 py-3 items-center"
					LeftButtonUp: -> navigate "/"
				}, =>
					TextBlock class: "text-foreground text-base font-bold", "Back to games"

		@content_for "no_chrome", true

		env = server.create_game_env!
		assert server.init env
		assert server.load_zil_files common, env
		assert server.load_zil_files config.modules, env
		game = server.create_game env

		history = nil
		game_record_id = nil

		if record_id
			record = Games\find record_id
			if record
				math.randomseed record.seed
				game_record_id = record.id
				history = {}
				table.insert history, { cmd: nil, output: game\resume nil }
				for _, cmd in ipairs record.commands or {} do
					table.insert history, { cmd: cmd, output: game\resume cmd }
		else
			game_record_id = Games\create game_id

		console_view = nil

		Outgoing = (line) ->
			bubble = TextBlock class: "mx-4 my-1 px-4 py-2 text-xl text-foreground bg-surface align-right", fontFamily: font, line
			bubble.BorderRadius = 12
			bubble.BorderBottomRightRadius = 0
			bubble

		Incoming = (line) ->
			TextBlock class: "p-2 text-xl text-foreground", fontFamily: font, line

		submit_cmd = (sender) ->
			text = sender.Text
			return if text == "" or not game
			sender.Text = ""
			console_view\addChild Outgoing text
			Games\addCommand game_record_id, text
			scene = game\resume text
			for line in scene\gmatch "[^\n]+" do
				console_view\addChild Incoming line

		-- Override layout footer with custom adventure chrome
		@content_for "footer", StackView class: "bg-header-bg flex-row px-4 py-2 gap-2 items-center", =>
			ImageView {
				class: "text-foreground-muted"
				Source: "assets/icons/back.svg?width=24&type=mask"
				LeftButtonUp: -> navigate "/"
			}
			Input
				class: "bg-surface flex-1 px-4 py-2 rounded text-foreground"
				PlaceholderText: "Enter command..."
				Name: "command"
				Submit: submit_cmd

		@content_for "title", config.title

		console_view = StackView class: "bg-background flex-col overflow-y-scroll h-full py-4", =>
			if history
				for _, entry in ipairs history do
					if entry.cmd
						Outgoing entry.cmd
					for line in entry.output\gmatch "[^\n]+" do
						Incoming line
			else
				scene = game\resume nil
				for line in scene\gmatch "[^\n]+" do
					Incoming line

		console_view.onScrollHeightChanged = () -> console_view\SetScrollTop console_view.ScrollHeight
		console_view
