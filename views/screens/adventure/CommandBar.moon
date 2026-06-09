import StackView, Input from require "orca.UIKit"

AdventureCommandBar = (on_submit) ->
	submit = (sender) ->
		text = sender.Text or ""
		text = text\gsub "[\r\n]+$", ""
		return if text == ""
		sender.Text = ""
		sender.Cursor = 0
		on_submit text if on_submit
		true

	key_down = (sender, event) ->
		key = event and event.keyCode or sender and sender.keyCode
		if key == 13 or key == 169
			return submit sender

		text = sender.Text or ""
		cursor = math.max 0, math.min sender.Cursor or #text, #text

		if key == 127
			if cursor > 0
				sender.Text = text\sub(1, cursor - 1) .. text\sub(cursor + 1)
				sender.Cursor = cursor - 1
			return true
		elseif key == 130
			sender.Cursor = math.max cursor - 1, 0
			return true
		elseif key == 131
			sender.Cursor = math.min cursor + 1, #text
			return true

		char = event and event.text or ""
		if key == 32
			char = " "
		elseif #char != 1 and event and event.character and event.character >= 32 and event.character <= 126
			char = string.char event.character

		if #char == 1 and char != "\n" and char != "\r"
			sender.Text = text\sub(1, cursor) .. char .. text\sub(cursor + 1)
			sender.Cursor = cursor + 1
			return true

	StackView {
		class: "command-bar"
	}, ->
		Input
			class: "input"
			PlaceholderText: "Enter command..."
			Name: "command"
			KeyDown: key_down

return AdventureCommandBar
