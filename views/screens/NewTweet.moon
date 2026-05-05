import StackView, TextBlock, Input, Button from require "orca.UIKit"

import Messages from require "model"
import navigate from require "chronicle/views/helpers"

class NewTweet extends require "orca.core.widget"
	title: "New Tweet"

	content: =>
		body_input = nil

		StackView class: "bg-background flex-col p-4 gap-4 h-full", =>
			TextBlock class: "text-xl font-bold text-foreground", "New Tweet"

			body_input = Input
				class: "bg-surface px-4 py-3 rounded text-foreground"
				PlaceholderText: "What's on your mind?"
				Name: "body"
				Multiline: true
				Height: 120

			Button {
				class: "bg-accent text-accent-foreground px-4 py-3 rounded font-bold"
				Click: ->
					text = body_input.Text
					return if text == ""
					pcall Messages.create, Messages, { chat: nil, body: text }
					navigate "/tweets"
			}, "Post"

			Button {
				class: "text-foreground-muted py-2"
				Click: -> navigate "/tweets"
			}, "Cancel"
