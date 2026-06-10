import StackView, TextBlock from require "orca.UIKit"

AdventureEmptyState = ->
	StackView {
		class: "adventure-empty"
	}, =>
		TextBlock {
			class: "message"
		}, "No game selected"
		StackView {
			class: "button"
			LeftButtonUp: -> @navigate "/"
		}, =>
			TextBlock {
				class: "label"
			}, "Back to games"

return AdventureEmptyState
