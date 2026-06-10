import StackView, TextBlock, Input, Button from require "orca.UIKit"

import Account, Users from require "model"

class SignUp extends require "orca.core.widget"
	title: "Sign Up"

	content: =>
		@content_for "no_chrome", true

		name_input     = nil
		user_id_input  = nil
		email_input    = nil
		password_input = nil

		StackView {
			class: "auth-screen"
		}, =>
			TextBlock { class: "title" }, "Create an account"
			TextBlock class: "subtitle", "Enter your details below"

			name_input = Input
				class: "input"
				PlaceholderText: "Full name"
				Name: "name"

			user_id_input = Input
				class: "input"
				PlaceholderText: "Username"
				Name: "userId"

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
					params = {
						name:     name_input.Text
						userId:   user_id_input.Text
						email:    email_input.Text
						password: password_input.Text
					}
					ok = pcall Account.signup, Account, params
					if ok
						pcall Account.signin, Account, params
						pcall Users.create, Users, params.userId, { name: params.name }
						@navigate "/"
			}, "Sign Up"

			Button {
				class: "link"
				Click: -> @navigate "/sign-in"
			}, "Already have an account? Sign in"
