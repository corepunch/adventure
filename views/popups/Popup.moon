import StackView, TextBlock from require "orca.UIKit"

class Popup extends require "orca.core.widget"
	new: (@args, ...) => super...
	content: =>
		title = @args.title or "Popup Title"
		text = @args.text or "This is a popup message."
		yes_label = @args.yes_label or "Yes"
		no_label = @args.no_label or "No"

		StackView class: "fixed items-center justify-center p-4 w-full", ->
			StackView {
				class: "bg-surface rounded-4 p-6 gap-4 w-full"
				LeftButtonUp: -> true
			}, ->
				TextBlock class: "text-xl font-bold text-foreground text-center", title
				TextBlock class: "text-sm text-muted-foreground", text
				StackView class: "flex-row gap-3 justify-center", ->
					TextBlock {
						class: "bg-muted rounded-3 px-8 py-3 text-foreground font-bold"
						LeftButtonUp: -> @on_result 0
					}, no_label
					TextBlock {
						class: "bg-primary rounded-3 px-8 py-3 text-primary-foreground font-bold"
						LeftButtonUp: -> @on_result 1
					}, yes_label
