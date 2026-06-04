import StackView, TextBlock, Button from require "orca.UIKit"

class Popup extends require "orca.core.widget"
	new: (@args, ...) => super...
	content: =>
		title = @args.title or "Popup Title"
		text = @args.text or "This is a popup message."
		yes_label = @args.yes_label or "Yes"
		no_label = @args.no_label or "No"

		StackView class: "popup", ->
			StackView class: "panel", LeftButtonUp: (-> true), ->
				TextBlock class: "title", title
				TextBlock class: "text", text
				StackView class: "actions", ->
					Button class: "secondary", Click: (-> @on_result 0), no_label
					Button class: "primary", Click: (-> @on_result 1), yes_label
