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
		assert server.load_zil_files common, env
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

	room_items = ->
		game\resume("room-items") or {}

	room_exits = ->
		game\resume("room-exits") or {}

	actions = ->
		action_items = {
			{ label: "Look Around", command: "look" }
			{ label: "Inventory", command: "inventory" }
		}

		for exit in *room_exits! do
			dir = if exit[1] then tostring exit[1] else ""
			room = if exit[2] then tostring exit[2] else ""
			table.insert action_items, {
				label: dir\sub(1, 1)\upper! .. dir\sub(2)\lower!
				detail: room
				command: "walk #{dir\lower!}"
			}

		add_item_actions = (items) ->
			for item in *items do
				name, verbs, children = table.unpack item
				for verb in *(verbs or {}) do
					table.insert action_items, {
						label: "#{verb\sub(1, 1)\upper!}#{verb\sub(2)\lower!} #{name}"
						command: "#{verb\lower!} #{name}"
					}
				add_item_actions children or {}

		add_item_actions room_items!
		action_items

	start!
	{ :entries, :submit, :room_items, :room_exits, :actions }

return AdventureSession
