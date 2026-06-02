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
			class: "muted-copy"
			HorizontalAlignment: "Center"
			VerticalAlignment: "Center"
		}, "No game selected"
		StackView {
			class: "secondary-button"
			AlignItems: "Center"
			BorderRadius: core.CornerRadius 12
			LeftButtonUp: -> navigate "/"
		}, =>
			TextBlock {
				class: "secondary-button-label"
				FontSize: 16
				LineHeight: 24
				FontWeight: "Bold"
			}, "Back to games"

return AdventureEmptyState
