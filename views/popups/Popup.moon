import StackView, TextBlock from require "orca.UIKit"
core = require "orca.core"

class Popup extends require "orca.core.widget"
	new: (@args, ...) => super...
	content: =>
		title = @args.title or "Popup Title"
		text = @args.text or "This is a popup message."
		yes_label = @args.yes_label or "Yes"
		no_label = @args.no_label or "No"

		StackView {
			class: "popup"
			HorizontalAlignment: "Stretch"
			AlignItems: "Center"
			JustifyContent: "Center"
		}, ->
			StackView {
				class: "panel"
				HorizontalAlignment: "Stretch"
				Spacing: 16
				BorderRadius: core.CornerRadius 16
				LeftButtonUp: -> true
			}, ->
				TextBlock {
					class: "title"
					FontWeight: "Bold"
					TextHorizontalAlignment: "Center"
				}, title
				TextBlock class: "text", text
				StackView {
					class: "actions"
					Direction: "Horizontal"
					Spacing: 12
					JustifyContent: "Center"
				}, ->
					TextBlock {
						class: "button secondary"
						BorderRadius: core.CornerRadius 12
						FontWeight: "Bold"
						LeftButtonUp: -> @on_result 0
					}, no_label
					TextBlock {
						class: "button primary"
						BorderRadius: core.CornerRadius 12
						FontWeight: "Bold"
						LeftButtonUp: -> @on_result 1
					}, yes_label
