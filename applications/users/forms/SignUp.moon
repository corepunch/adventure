ui = require "orca.UIKit"
routing = require "routing"

import Account, Users from require "model"
import ErrorMessage from require "assets.components"

fields = {
	{ label: "Name", attribute: "name" }
	{ label: "Username", attribute: "userId" }
	{ label: "Email", attribute: "email" }
	{ label: "Password", attribute: "password" }
}

class SignUp extends ui.Form
	apply: => "legacy-auth-form"

	body: =>
		p ".title", "Create a new account"
		p ".description", "To use mobile banking enter you details"
		for item in *fields 
			ui.Label ".label", for: item.attribute, item.label
			ui.Input "##{item.attribute}.input"
				Name: item.attribute
				PlaceholderText: item.label
		ui.Button ".primary", Type: "Submit", "Sign up"
		ErrorMessage error: @error if @error

	Submit: =>
		params = @populateInputs!
		Account\signup params
		Account\signin params
		Users\create params.userId, name: params.name
		routing.navigate "/"
