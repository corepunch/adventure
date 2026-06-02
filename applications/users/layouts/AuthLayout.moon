ui = require "orca.UIKit"
constants = require "assets.constants"

import Page from require "routing"

class AuthLayout extends Page
	body: =>
		grid Rows: "48px auto", ->
			h6 ".legacy-auth-header", "Auth"
			@content!
