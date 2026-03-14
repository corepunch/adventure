ui = require "orca.ui"

class Popup extends ui.Screen
	class: "bg-muted/80 p-6"
	body: =>
		stack class: "bg-neutral-2 p-6 rounded-4 flex-col gap-4 align-middle", ->
			p class: "text-neutral-9 text-xl text-center font-bold", "Resume Game?"
			p class: "text-neutral-6 text-lg", @text or "This is a popup message. You can set the text and actions when showing the popup."
			grid class: "flex-row gap-4 mt-4 justify-center", Columns: "auto auto", ->
				button 
					class: "py-2 text-center bg-primary text-neutral-9 rounded hover:bg-primary/80",
					onClick: -> @DialogResult = 1
					text: "Yes"
				button 
					class: "py-2 text-center bg-neutral-4 text-neutral-9 rounded hover:bg-neutral-5",
					onClick: -> @DialogResult = 0
					text: "No"
