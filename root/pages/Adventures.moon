import StackView, Node2D from require "orca.ui"
import Header, Footer from require "root.components"
routing = require "routing"

class Entry extends StackView
	class: "flex-col w-full p-2 border-muted-foreground"
	body: =>
		@BorderBottomWidth = 1
		p class: "text-amber-200 text-2xl", @title
		p class: "text-lg", @content
	onLeftMouseUp: => 
		@BorderColor = "#ffff00"
		-- routing.navigate "/adventure"
		@navigate "/adventure"

class Adventure extends Node2D
	title: "Adventure"
	class: "flex-col w-full gap-2"
	body: =>
		grid rows: "88px auto 88px", ->
			Header title: @title
			stack class: "flex-col gap-2", ->
				Entry title: "The Mysterious Forest Clearing", content: "You find yourself in a mysterious forest clearing."
				Entry title: "Dragon Lair", content: "You enter a dark cave, the air thick with smoke and the scent of sulfur."
			Footer!
