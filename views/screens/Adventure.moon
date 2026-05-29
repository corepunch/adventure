import StackView, TextBlock from require "orca.UIKit"
Application = require "orca.core.application"

import Games, Sessions from require "model"
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
		@title = "Adventure"
		@chrome = nil

		app    = Application.current false
		data   = app and app.nav_data
		game_id   = data and data.game
		requested_session_id = data and data.session
		config = game_id and Games\definition game_id

		unless config
			return StackView class: "bg-background flex-col p-4 gap-4 h-full justify-center", =>
				TextBlock class: "text-muted-foreground align-middle-center", "No game selected"
				StackView {
					class: "bg-surface rounded-3 px-4 py-3 items-center"
					LeftButtonUp: -> navigate "/"
				}, =>
					TextBlock class: "text-foreground text-base font-bold", "Back to games"

		@title = config.title

		env = server.create_game_env!
		assert server.init env
		assert server.load_zil_files common, env
		assert server.load_zil_files config.modules, env
		game = server.create_game env

		history = nil
		session_id = nil
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
			Sessions\addCommand session_id, text
			scene = game\resume text
			for line in scene\gmatch "[^\n]+" do
				console_view\addChild Incoming line

		@chrome = {
			placeholder: "Enter command..."
			name: "command"
			on_back: -> navigate "/"
			on_submit: submit_cmd
		}

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
