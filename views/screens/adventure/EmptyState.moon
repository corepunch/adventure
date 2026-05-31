import StackView, TextBlock from require "orca.UIKit"
import navigate from require "chronicle/views/helpers"

class AdventureEmptyState
	render: =>
		StackView class: "bg-background flex-col p-4 gap-4 h-full justify-center", =>
			TextBlock class: "text-muted-foreground align-middle-center", "No game selected"
			StackView {
				class: "bg-surface rounded-3 px-4 py-3 items-center"
				LeftButtonUp: -> navigate "/"
			}, =>
				TextBlock class: "text-foreground text-base font-bold", "Back to games"
