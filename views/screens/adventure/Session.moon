import Sessions from require "model"

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

class AdventureSession
	new: (@game_id, @requested_session_id, @config) =>
		@game = nil
		@session_id = nil
		@history = nil
		@start!

	start: =>
		env = server.create_game_env!
		assert server.init env
		assert server.load_zil_files common, env
		assert server.load_zil_files @config.modules, env
		@game = server.create_game env

		session = if @requested_session_id
			Sessions\find @requested_session_id
		else
			Sessions\find_by_game_id @game_id

		if session
			math.randomseed session.seed
			@session_id = session.id
			@history = {}
			table.insert @history, { cmd: nil, output: @game\resume nil }
			for _, cmd in ipairs session.commands or {} do
				table.insert @history, { cmd: cmd, output: @game\resume cmd }
		else
			@session_id = Sessions\create @game_id

	entries: =>
		unless @history
			@history = { { cmd: nil, output: @game\resume nil } }
		@history

	submit: (text) =>
		text = text or ""
		text = text\gsub "[\r\n]+$", ""
		return nil if text == "" or not @game
		Sessions\addCommand @session_id, text
		entry = { cmd: text, output: @game\resume text }
		table.insert @entries!, entry
		entry
