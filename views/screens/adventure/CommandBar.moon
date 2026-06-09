import StackView, Input from require "orca.UIKit"

AdventureCommandBar = (on_submit) ->
	StackView class: "command-bar", ->
		Input
			class: "input"
			PlaceholderText: "Enter command..."
			Submit: (sender) => 
				text = sender.Text or ""
				text = text\gsub "[\r\n]+$", ""
				return if text == ""
				sender.Text = ""
				sender.Cursor = 0
				on_submit text if on_submit
				true

return AdventureCommandBar
