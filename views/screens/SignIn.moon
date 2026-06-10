import StackView, TextBlock, Input, Button from require "orca.UIKit"

import Account from require "model"

class SignIn extends require "orca.core.widget"
	title: "Sign In"

	content: =>
		@content_for "no_chrome", true

		email_input    = nil
		password_input = nil

		StackView {
			class: "auth-screen"
		}, =>
			TextBlock { class: "title" }, "Welcome back"
			TextBlock class: "subtitle", "Sign in to your account"

			email_input = Input
				class: "input"
				PlaceholderText: "Email"
				Name: "email"

			password_input = Input
				class: "input"
				PlaceholderText: "Password"
				Name: "password"

			Button {
				class: "primary"
				Click: ->
					params = { email: email_input.Text, password: password_input.Text }
					ok = pcall Account.signin, Account, params
					if ok then @navigate "/"
			}, "Sign In"

			Button {
				class: "link"
				Click: -> @navigate "/sign-up"
			}, "No account? Create one"
