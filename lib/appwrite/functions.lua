local network = require "orca.network"
local openai_key = require "openai.api_key"
local projectId = "6793939300106a97df4f"
local databaseId = "679bb7320003ab334979"
local endpoint = "https://cloud.appwrite.io/v1"
local headers = {
	-- ["X-Appwrite-Key"] = apiKey,
	["X-Appwrite-Project"] = projectId,
	["Content-Type"] = "application/json",
}
local collections = {
	friends = "679bb73e002649c14d37",
	users = "679bd1410007f06de0fb",
	transactions = "679df0510029b54b28be",
	messages = "67a261a400165972fc59",
	chat_members = "chat-members",
}

local url = function(tbl)
	return table.concat(tbl, '/')
end

local function encode_json(data)
	local buffer, isArray = {}, #data > 0
	for k, v in (isArray and ipairs or pairs)(data) do
		if string.sub(k, 1, 2) ~= "__" then
			local value
			if type(v) == 'table' then
				value = encode_json(v)
			elseif type(v) == 'number' then
				value = string.format('%g', v)
			elseif type(v) == 'boolean' then
				value = v and "true" or "false"
			elseif v == nil then
				value = "null"
			else
				value = string.format('"%s"', tostring(v))
			end

			if isArray then
				table.insert(buffer, value)
			else
				table.insert(buffer, string.format('"%s":%s', k, value))
			end
		end
	end
	return (isArray and "[" or "{") .. table.concat(buffer, ",") .. (isArray and "]" or "}")
end

-- Function to URL-encode a string
local function url_encode(str)
	if not str then return "" end
	str = string.gsub(str, "([^%w%-%.%_%~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
	return str
end

local compile_query = function(...)
	local tmp = {}
	for i, v in ipairs {...} do
		table.insert(tmp, string.format("queries[%d]=%s", i-1, url_encode(encode_json(v))))
	end
	return '?'..(table.concat(tmp, "&"))
end

local appwrite = {}

local room_schema = {
  type = "object",
  properties = {
    id = {
      type = "string",
      description = "Unique identifier of the room"
    },
    title = {
      type = "string",
      description = "Short title of the room"
    },
    description = {
      type = "string",
      description = "Detailed description of what the player sees"
    },
    objects = {
      type = "array",
      items = {
        type = "object",
        properties = {
          name = {
            type = "string"
          },
          description = {
            type = "string"
          },
          state = {
            type = "string",
            enum = { "default", "opened", "taken", "locked" },
            description = "Current state of the object"
          }
        },
        required = { "name", "description" }
      }
    },
    exits = {
      type = "object",
      description = "Map of available exits to other room IDs",
      additionalProperties = {
        type = "string"
      }
    }
  },
  required = { "id", "title", "description", "objects", "exits" }
}

local schema = {
	name = "AdventureScene",
	description = "Scene description and choices for the text adventure",
	schema = {
		type = "object",
		properties = {
			scene = {
				type = "string",
				description = "The vivid description of the current scene"
			},
			choices = {
				type = "array",
				description = "List of available choices for the player",
				items = { type = "string" }
			}
		},
		required = { "scene", "choices" },
		additionalProperties = false
	},
	strict = true
}

function appwrite.test_openai(system, user)
	local data = { 
			model= "gpt-4o-mini",
  		messages = {
				{ role = "system", content = system },
				{ role = "user", content = user }
			},
			response_format = {
				type = "json_schema",
				json_schema = {
					name = "AdventureScene",
					description = "Scene description and choices for the text adventure",
					schema = schema,
					strict = true
				}
			}
		}
	return network.fetch('https://api.openai.com/v1/chat/completions', {
		method = "POST",
		body = encode_json(data),
		headers = {
			["Content-Type"] = "application/json; charset=utf-8",
			["Authorization"] = openai_key,
		},
		nocookies = true
	})
end

function appwrite.signInAccount(user)
	return network.fetch(url{endpoint,"account","sessions","email"}, {
		method = "POST",
		body = encode_json(user),
		headers = headers,
		nocookies = true
	})
end

function appwrite.signOutAccount()
	return network.fetch(url{endpoint,"account","sessions", "current"}, {
		method = "DELETE",
		headers = headers
	})
end

function appwrite.createUserAccount(user)
	return network.fetch(url{endpoint,"account"}, {
		method = "POST",
		body = encode_json(user),
		headers = headers
	})
end

function appwrite.getAccount()
	return network.fetch(url{endpoint,"account"}, {
		method = "GET",
		headers = headers
	})
end

function appwrite.listCollections(collection, ...)
	local q = compile_query(...)
	local col = collections[collection]
	local db = databaseId
	return network.fetch(url{endpoint,"databases",db,"collections",col,"documents"}..q, {
		method = "GET",
		headers = headers
	})
end

function appwrite.createDocumentWithId(collection, documentId, document)
	local col = collections[collection]
	local db = databaseId
	print(documentId, document)
	return network.fetch(url{endpoint,"databases",db,"collections",col,"documents"}, {
		method = "POST",
		headers = headers,
		body = encode_json {
			documentId = documentId,
			data = document
		}
	})
end

function appwrite.createDocument(collection, document)
	local col = collections[collection]
	local db = databaseId
	return network.fetch(url{endpoint,"databases",db,"collections",col,"documents"}, {
		method = "POST",
		headers = headers,
		body = encode_json {
			documentId = "unique()",
			data = document
		}
	})
end

return appwrite