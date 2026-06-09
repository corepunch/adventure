Application = require "orca.core.application"

decode_query_component = (value) ->
	return value unless value
	value = value\gsub "+", " "
	value = value\gsub "%%(%x%x)", (hex) -> string.char tonumber hex, 16
	value

parse_query = (query) ->
	data = {}
	return data unless query and query != ""

	for pair in query\gmatch "[^&]+" do
		key, value = pair\match "([^=]*)=(.*)"
		if key and key ~= ""
			data[decode_query_component key] = decode_query_component value

	data

-- Navigate to a route, attaching nav_data for the destination screen.
-- nav_data is always set (cleared to nil when not provided) so stale data
-- from a previous navigation never leaks into the next screen.
navigate = (route, data) ->
	app = Application.current false
	if app
		if data == nil and type(route) == "string"
			path, query = route\match "^(.-)%?(.*)$"
			if query and query != ""
				data = parse_query query
				route = path
		app.nav_data = data
		app\navigate route
	return true

return { :navigate }
