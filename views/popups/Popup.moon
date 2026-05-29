import StackView, TextBlock from require "orca.UIKit"

class Popup extends require "orca.core.widget"
	content: =>
		self = @
		title = @title or "Popup Title"
		text = @text or "This is a popup message."
		yes_label = @yes_label or "Yes"
		no_label = @no_label or "No"

		StackView class: "fixed inset-0 bg-black/55 items-center justify-center p-4", ->
			StackView {
				class: "bg-surface rounded-4 p-6 gap-4 w-full max-w-md"
				LeftButtonUp: -> true
			}, ->
				TextBlock class: "text-xl font-bold text-foreground", title
				TextBlock class: "text-sm text-muted-foreground", text
				StackView class: "flex-row gap-3 justify-end", ->
					StackView {
						class: "bg-background rounded-3 px-4 py-3"
						LeftButtonUp: ->
							self.on_result and self.on_result 0
					}, ->
						TextBlock class: "text-foreground font-bold", no_label
					StackView {
						class: "bg-primary rounded-3 px-4 py-3"
						LeftButtonUp: ->
							self.on_result and self.on_result 1
					}, ->
						TextBlock class: "text-primary-foreground font-bold", yes_label
