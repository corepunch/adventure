ui = require "orca.UIKit"
constants = require "assets.constants"

import Page from require "routing"

class AuthLayout extends Page
	body: =>
		grid ".legacy-auth", Rows: "48px auto", ->
			h6 ".header", "Auth"
			@content!
