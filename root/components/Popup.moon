ui = require "orca.UIKit"

class Popup extends ui.Screen
	class: "bg-dark-1/95 p-6"
	body: =>
		stack class: "bg-neutral-3 p-6 rounded-4 flex-col gap-4 align-middle", "onNode.LeftMouseUp": (-> true), ->
			p class: "text-neutral-9 text-xl text-center font-bold", "Resume Game?"
			p class: "text-neutral-6 text-lg", @text or "This is a popup message. You can set the text and actions when showing the popup."
			grid class: "flex-row gap-4 mt-2 justify-center", Columns: "auto auto", ->
				button 
					class: "py-3 text-center bg-neutral-4 text-neutral-9 rounded hover:bg-neutral-5",
					onClick: -> @DialogResult = 2
					text: "No"
				button 
					class: "py-3 text-center bg-primary text-neutral-9 rounded hover:bg-primary/80",
					onClick: -> @DialogResult = 1
					text: "Yes"

	"onNode.LeftMouseUp": (event) =>
		@DialogResult = 0
		return true