import StackView, Input from require "orca.UIKit"

AdventureCommandBar = (on_submit) ->
	StackView class: "command-bar", ->
		Input
			class: "input"
			PlaceholderText: "Enter command..."
			Submit: (sender, evt) => 
				text = evt.Text\gsub "[\r\n]+$", ""
				return if text == ""
				sender\Clear!
				on_submit text if on_submit
				true

return AdventureCommandBar
