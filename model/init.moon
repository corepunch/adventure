Model = require "appwrite.model"
query = require "appwrite.query"
json = require "orca.parsers.json"

encode_json = (val) ->
	t = type val
	if t == "string"
		escaped = val\gsub('\\', '\\\\')\gsub('"', '\\"')\gsub('\n', '\\n')\gsub('\r', '\\r')\gsub('\t', '\\t')\gsub('\f', '\\f')
		return '"' .. escaped .. '"'
	elseif t == "number" or t == "boolean"
		return tostring val
	elseif t == "table"
		n = #val
		if n > 0
			parts = {}
			for i = 1, n
				parts[i] = encode_json val[i]
			return '[' .. table.concat(parts, ',') .. ']'
		else
			parts = {}
			for k, v in pairs val
				table.insert parts, '"' .. tostring(k) .. '":' .. encode_json(v)
			return '{' .. table.concat(parts, ',') .. '}'
	else
		return 'null'

context = {}

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
	readAll: =>
		file = io.open @path, "r"
		unless file then return {}
		content = file\read "*a"
		file\close!
		ok, data = pcall -> json.decode content
		if ok and type(data) == "table" then data else {}
	saveAll: (data) =>
		os.execute "mkdir -p tmp"
		file = io.open @path, "w"
		unless file then return false
		file\write encode_json data
		file\close!
		true
	create: (gameId) =>
		math.randomseed os.time!
		games = @readAll!
		id = tostring(os.time!) .. "_" .. tostring(math.random 1000, 9999)
		games[id] = gameId: gameId, createdAt: os.time!, commands: {}
		@saveAll games
		id
	addCommand: (id, command) =>
		games = @readAll!
		unless games[id] then return false
		table.insert games[id].commands, command
		@saveAll games
	findAll: =>
		games = @readAll!
		result = {}
		for id, game in pairs games
			table.insert result, {id: id, gameId: game.gameId, createdAt: game.createdAt, commands: game.commands or {}}
		result

return {
	:Account
	:Users
	:Chats
	:Transactions
	:Messages
	:Games
}