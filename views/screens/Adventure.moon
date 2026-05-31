import Grid, StackView, TextBlock, ImageView, Input from require "orca.UIKit"
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
		app    = Application.current false
		data   = app and app.nav_data
		game_id   = data and data.game
		requested_session_id = data and data.session
		config = game_id and Games\definition game_id

		unless config
			@content_for "title", "Adventure"
			return StackView class: "bg-background flex-col p-4 gap-4 h-full justify-center", =>
				TextBlock class: "text-muted-foreground align-middle-center", "No game selected"
				StackView {
					class: "bg-surface rounded-3 px-4 py-3 items-center"
					LeftButtonUp: -> navigate "/"
				}, =>
					TextBlock class: "text-foreground text-base font-bold", "Back to games"

		@content_for "title", config.title
		@content_for "header", Grid {
			class: "bg-header-background items-center overflow-x-hidden"
			Columns: "80px 1fr"
		}, =>
			ImageView {
				class: "align-middle-center text-accent-foreground"
				Source: "assets/icons/back.svg?width=32&type=mask"
				LeftButtonUp: -> navigate "/"
			}
			TextBlock {
				class: "w-full h-full align-middle-left text-base font-bold text-left text-nowrap text-ellipsis text-accent-foreground pr-5"
				fontFamily: font
			}, config.title

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
			TextBlock class: "mx-4 my-1 px-4 py-2 text-base text-foreground bg-surface align-right rounded-3", fontFamily: font, line

		Incoming = (line) ->
			TextBlock class: "p-2 text-base text-foreground", fontFamily: font, line

		command_input = nil

		submit_cmd = (sender) ->
			text = sender.Text or ""
			text = text\gsub "[\r\n]+$", ""
			return if text == "" or not game
			sender.Text = ""
			sender.Cursor = 0
			console_view\addChild Outgoing text
			Sessions\addCommand session_id, text
			scene = game\resume text
			for line in scene\gmatch "[^\n]+" do
				console_view\addChild Incoming line

		command_key_down = (sender, event) ->
			key = event and event.keyCode or sender and sender.keyCode
			if key == 13 or key == 169
				submit_cmd sender
				return true

			text = sender.Text or ""
			cursor = math.max 0, math.min sender.Cursor or #text, #text

			if key == 127
				if cursor > 0
					sender.Text = text\sub(1, cursor - 1) .. text\sub(cursor + 1)
					sender.Cursor = cursor - 1
				return true
			elseif key == 130
				sender.Cursor = math.max cursor - 1, 0
				return true
			elseif key == 131
				sender.Cursor = math.min cursor + 1, #text
				return true

			char = event and event.text or ""
			if key == 32
				char = " "
			elseif #char != 1 and event and event.character and event.character >= 32 and event.character <= 126
				char = string.char event.character

			if #char == 1 and char != "\n" and char != "\r"
				sender.Text = text\sub(1, cursor) .. char .. text\sub(cursor + 1)
				sender.Cursor = cursor + 1
				return true

		@content_for "footer", StackView class: "bg-footer-background px-4 py-2 items-center", =>
			command_input = Input
				class: "bg-surface w-full h-12 px-4 py-2 rounded text-base text-foreground placeholder-muted-foreground text-nowrap text-clip overflow-x-hidden"
				fontFamily: font
				PlaceholderText: "Enter command..."
				Name: "command"
				KeyDown: command_key_down

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
		command_input\setFocus! if command_input
		console_view
