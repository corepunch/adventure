Model = require "appwrite.model"
query = require "appwrite.query"
json = require "orca.parsers.json"
games_config = require "config.games"

context = {}

class Game
	new: (attrs={}) =>
		for k, v in pairs attrs
			@[k] = v

	url_params: (req, ...) =>
		params = { game: @id }
		"Adventure", nil, params, ...

	cover_source: =>
		"assets/games/#{@id}"

	@from_config: (id, config) =>
		Game {
			id: id
			title: config.title
			description: config.description
			modules: config.modules
		}

class SavedGame extends Game
	url_params: (req, ...) =>
		params = { game: @game_id, saved_game: @id }
		"Adventure", nil, params, ...

	command_count: =>
		@commands and #@commands or 0

	@from_record: (record, config) =>
		SavedGame {
			id: record.id
			game_id: record.gameId
			title: config and config.title or record.gameId
			description: config and config.description or ""
			modules: config and config.modules or {}
			commands: record.commands or {}
			seed: record.seed
			createdAt: record.createdAt
		}

class Account extends Model
	cached: nil
	auth: => 
		if context.account return context.account
		res = @getaccount!
		context.account = res\json!
		return context.account
	signin: (params) => 
		response = super params
		return response\json!
	signup: (params) => 
		response = super params
		return response\json!
	signout: () =>
		response = super!
		export context = {}
		return response\json!

class Users extends Model
	cached: nil
	getFullName: (user) => user.name
	auth: => 
		-- return {["$id"]: "679bd1b50008b3e1de9d" }
		if context.user return context.user
		account = Account\auth!
		response = @list "users", query.Equal("$id", account["$id"])
		data = response\json!
		context.user = data.documents[1]
		return context.user

	search: (search) =>
		response = @list "users", query.Or(
				query.Search("name", search), 
				query.Search("$id", search)
			),
			query.Limit(15)
		data = response\json!
		return data.documents

	find: (userId) =>
		response = @list "users", query.Contains("$id", userId)
		data = response\json!
		return data.documents[1]

	create: (...) => @createWithId "users", ...

class Chats extends Model
	findAll: (user) =>
		-- chats = @list "chat_members",
		-- 	query.Equal("userId", user["$id"]),
		-- 	query.Select("chatId")
		-- print chats\text!
		response = @list "friends", 
			query.Contains("users2", user["$id"]),
			query.Select("*", "users.*")
		data = response\json!
		return data.documents

	find: (chatId) =>
		response = @list "friends", 
			query.Contains("$id", chatId),
			query.Select("*", "users.*")
		data = response\json!
		return data.documents[1]

	getPartner: (chat, user) => 
		for other in *chat.users
			if other["$id"] != user["$id"]
				return other

	create: (user) =>
		me = Users\auth!
		super "friends"
			users: { me["$id"], user["$id"] }
			users2: { me["$id"], user["$id"] }
			status: "pending"

class Messages extends Model
	findAll: (chat, after) =>
		response = @list "messages", 
			query.Equal("chatId", chat["$id"]),
			query.GreaterThan("$createdAt", after or "1970-01-01T00:00:00.000"),
			query.OrderAsc("$createdAt"),
			query.Select("body", "$createdAt", "sender.$id"),
			query.Limit(50)
		data = response\json!
		return data.documents

	create: (params) =>
		sender = Users\auth!
		super "messages"
			sender: sender["$id"]
			body: params.body
			chatId: params.chat

class Transactions extends Model
	find: (id) =>
		response = @list "transactions", query.Contains("$id", id)
		data = response\json!
		return data.documents[1]

	findAll: (user, limit) =>
		response = @list "transactions", 
			query.Or(query.Equal("sender", user["$id"]), query.Equal("beneficiary", user["$id"])),
			query.Select("*", "sender.*", "beneficiary.*"),
			if limit then query.Limit(limit) else nil
		data = response\json!
		return data.documents

	findTotal: (user) =>
		sum = 0
		for t in *Transactions\findAll user
			sum += t.amount
		return sum

	formatAmount: (transaction) => string.format('$%.02f', transaction.amount/100)

class Games
	path: "tmp/games.json"
	catalog: =>
		keys = {}
		for k in pairs games_config do table.insert keys, k
		table.sort keys

		games = {}
		for key in *keys do
			table.insert games, Game\from_config key, games_config[key]
		games

	definition: (gameId) =>
		config = games_config[gameId]
		return nil unless config
		Game\from_config gameId, config

	view: (gameId) =>
		saved = @saved gameId
		return saved if saved
		@definition gameId

	saved: (gameId) =>
		for record in *@readAll!
			if record.gameId == gameId
				return SavedGame\from_record record, games_config[gameId]
		nil

	find_by_game_id: (gameId) =>
		@saved gameId

	ongoing: =>
		saved = {}
		for record in *@readAll!
			config = games_config[record.gameId]
			table.insert saved, SavedGame\from_record record, config
		saved

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
		assert @saveAll games
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
			assert @saveAll games
			return true
	delete: (id) =>
		games = @readAll!
		for i, game in ipairs games do
			if game.id == id
				table.remove games, i
				return @saveAll games
		print 'Game not found: ' .. id
		return false
	findAll: => 
		return @readAll!

return {
	:Game
	:SavedGame
	:Account
	:Users
	:Chats
	:Transactions
	:Messages
	:Games
}
