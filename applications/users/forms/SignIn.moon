ui = require "orca.UIKit"
routing = require "routing"

import Account from require "model"
import ErrorMessage from require "assets.components"

fields = {
	{ label: "Email", attribute: "email" }
	{ label: "Password", attribute: "password" }
}

class SignIn extends ui.Form
	apply: => "legacy-auth-form"
	Submit: => routing.navigate "/" if Account\signin @populateInputs!
	body: =>
		handleSignin = (params) -> routing.navigate "/" if Account\signin params
		p ".legacy-form-title", "Log in with existing account"
		p ".legacy-form-description", "To use mobile banking now"
		for item in *fields 
			ui.Label ".legacy-form-label", For: item.attribute, item.label
			ui.Input "##{item.attribute}.legacy-form-input"
				Name: item.attribute
				PlaceholderText: item.label
		ui.Button ".legacy-primary-button", Type: "Submit", "Sign in"
		ui.Button ".legacy-link-button", Click: (=> routing.navigate "/sign-up"), "No account? Create one now"
		stack ".legacy-link-list", ->
			links = {
				{ label: "Default signin", func: -> handleSignin email: "igor.chernakov@gmail.com", password: "qwerty1234" },
				{ label: "Test1", func: -> handleSignin email: "test1@gmail.com", password: "qwer1234" },
				{ label: "Test2", func: -> handleSignin email: "test2@gmail.com", password: "qwer1234" },
			}
			for link in *links
				ui.Button ".legacy-small-link", Click: link.func, link.label
		ErrorMessage error: @error if @error
