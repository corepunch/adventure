import StackView, Node2D from require "orca.ui"
-- import Header, Footer from require "root.components"

import Header, Footer from require "root.components"

class Entry extends StackView
	apply: -> 'flex-col w-full p-2'
	body: =>
		@BorderTopWidth = 10
		p class: "text-amber-200 text-2xl", @title
		p class: "text-lg", @content

class Adventure extends Node2D
	title: "Adventure"
	apply: -> 'flex-col w-full gap-2'
	body: =>
		grid rows: "88px auto 88px", ->
			Header "Hello"
			stack class: "flex-col", ->
				Entry title: "The Mysterious Forest Clearing", content: "You find yourself in a mysterious forest clearing."
				Entry title: "Dragon Lair", content: "You enter a dark cave, the air thick with smoke and the scent of sulfur."
			Footer!
