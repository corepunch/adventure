Application = require "orca.core.application"

import Account from require "model"

AUTH_ROUTES = { ["/sign-in"]: true, ["/sign-up"]: true }

class App extends Application
	layout: require "chronicle/views/layout"
	views_prefix: "chronicle/views/screens"

	@include_helpers {
		app_title: => "Chronicle"
		current_route: => @current_route or "/"
	}

	_dispatch: (req) =>
		route = if type(req) == "table" then req.path or req.url or req.route else req

		if route == "/sign-out"
			pcall Account.signout, Account
			route = "/sign-in"
			req   = "/sign-in"

		unless AUTH_ROUTES[route]
			ok = pcall Account.auth, Account
			unless ok
				route = "/sign-in"
				req   = "/sign-in"

		@current_route = route or "/"
		App.__parent.dispatch self, req

	navigate: (route) =>
		@activate_route route

	[Adventures:    "/"          ]: => render: true
	[OngoingGames:  "/games"     ]: => render: true
	[Adventure:     "/adventure" ]: => render: true
	[SignIn:        "/sign-in"   ]: => render: true
	[SignUp:        "/sign-up"   ]: => render: true
