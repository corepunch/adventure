import StackView, TextBlock from require "orca.UIKit"
core = require "orca.core"
import navigate from require "chronicle/views/helpers"

AdventureEmptyState = ->
	StackView {
		class: "adventure-empty"
		Direction: "Vertical"
		Spacing: 16
		VerticalAlignment: "Stretch"
		JustifyContent: "Center"
	}, =>
		TextBlock {
			class: "message"
			HorizontalAlignment: "Center"
			VerticalAlignment: "Center"
		}, "No game selected"
		StackView {
			class: "button"
			AlignItems: "Center"
			BorderRadius: core.CornerRadius 12
			LeftButtonUp: -> navigate "/"
		}, =>
			TextBlock {
				class: "label"
				FontSize: 16
				LineHeight: 24
				FontWeight: "Bold"
			}, "Back to games"

return AdventureEmptyState
