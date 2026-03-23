json = require "orca.parsers.json"

class Games
	path: "tmp/games.json"
	readAll: =>
		file = io.open @path, "r"
		unless file then return {}
		content = file\read "*a"
		file\close!
		return json.decode content
	saveAll: (data) =>
		os.execute "mkdir -p tmp"
		file = io.open @path, "w"
		unless file then return false
		file\write json.encode data
		file\close!
		return true
	create: (gameId) =>
		seed = os.time!
		math.randomseed seed
		games = @readAll!
		id = tostring(os.time!) .. "_" .. tostring(math.random 1000, 9999)
		created = tostring(os.time!)
		table.insert games, id: id, gameId: gameId, createdAt: created, seed: seed, commands: {}
		@saveAll games
		return id
	find: (id) =>
		for _, game in pairs @readAll! do
			if game.id == id then return game
		return nil
	addCommand: (id, command) =>
		games = @readAll!
		for _, game in pairs games do if game.id == id then
			game.commands = game.commands or {}
			table.insert game.commands, command
			@saveAll games
			return true
	delete: (id) =>
		games = @readAll!
		for i, game in ipairs games do
			if game.id == id then
				table.remove games, i
				return @saveAll games
		print 'Game not found: ' .. id
		return false
	findAll: =>
		return @readAll!

return { :Games }
