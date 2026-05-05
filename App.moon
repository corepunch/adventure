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

	dispatch: (req) =>
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

	[Adventures:    "/"            ]: => render: true
	[OngoingGames:  "/games"       ]: => render: true
	[Adventure:     "/adventure"   ]: => render: true
	[SendMoney:     "/send-money"  ]: => render: true
	[Settings:      "/settings"    ]: => render: true
	[Tweets:        "/tweets"      ]: => render: true
	[NewTweet:      "/new-tweet"   ]: => render: true
	[Search:        "/search"      ]: => render: true
	[UserProfile:   "/user"        ]: => render: true
	[Transaction:   "/transaction" ]: => render: true
	[Chat:          "/chat"        ]: => render: true
	[SignIn:        "/sign-in"     ]: => render: true
	[SignUp:        "/sign-up"     ]: => render: true
