import StackView, TextBlock from require "orca.UIKit"
import navigate from require "chronicle/views/helpers"

AdventureEmptyState = ->
	StackView {
		class: "adventure-empty"
	}, =>
		TextBlock {
			class: "message"
		}, "No game selected"
		StackView {
			class: "button"
			LeftButtonUp: -> navigate "/"
		}, =>
			TextBlock {
				class: "label"
			}, "Back to games"

return AdventureEmptyState
