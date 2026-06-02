import StackView, TextBlock, Input, Button from require "orca.UIKit"
core = require "orca.core"

import Account, Users from require "model"
import navigate from require "chronicle/views/helpers"

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
			Direction: "Vertical"
			Spacing: 16
			VerticalAlignment: "Stretch"
			JustifyContent: "Center"
		}, =>
			TextBlock { class: "auth-title", FontWeight: "Bold" }, "Create an account"
			TextBlock class: "screen-subtitle", "Enter your details below"

			name_input = Input
				class: "form-input"
				BorderRadius: core.CornerRadius 8
				PlaceholderText: "Full name"
				Name: "name"

			user_id_input = Input
				class: "form-input"
				BorderRadius: core.CornerRadius 8
				PlaceholderText: "Username"
				Name: "userId"

			email_input = Input
				class: "form-input"
				BorderRadius: core.CornerRadius 8
				PlaceholderText: "Email"
				Name: "email"

			password_input = Input
				class: "form-input"
				BorderRadius: core.CornerRadius 8
				PlaceholderText: "Password"
				Name: "password"

			Button {
				class: "primary-button"
				BorderRadius: core.CornerRadius 8
				FontWeight: "Bold"
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
						navigate "/"
			}, "Sign Up"

			Button {
				class: "link-button"
				Click: -> navigate "/sign-in"
			}, "Already have an account? Sign in"
