import StackView, Input from require "orca.UIKit"

class AdventureCommandBar
	new: (@font, @on_submit) =>
		@input = nil

	submit: (sender) =>
		text = sender.Text or ""
		text = text\gsub "[\r\n]+$", ""
		return if text == ""
		sender.Text = ""
		sender.Cursor = 0
		on_submit = @on_submit
		on_submit text if on_submit

	key_down: (sender, event) =>
		key = event and event.keyCode or sender and sender.keyCode
		if key == 13 or key == 169
			@submit sender
			return true

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

	focus: =>
		@input\setFocus! if @input

	render: =>
		text_font = @font
		owner = @
		key_down = (sender, event) -> @key_down sender, event

		StackView class: "bg-footer-background px-4 py-2 items-center", =>
			owner.input = Input
				class: "bg-surface w-full h-12 px-4 py-2 rounded text-base text-foreground placeholder-muted-foreground text-nowrap text-clip overflow-x-hidden"
				fontFamily: text_font
				PlaceholderText: "Enter command..."
				Name: "command"
				KeyDown: key_down
