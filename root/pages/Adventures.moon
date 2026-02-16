import StackView, Node2D from require "orca.ui"
import Header, Footer from require "root.components"
routing = require "routing"
games = require "config.games"

class Entry extends StackView
	class: "flex-col w-full p-2 border-muted-foreground"
	body: =>
		@BorderBottomWidth = 1
		p class: "text-foreground text-2xl", @title
		p class: "text-lg text-muted-foreground", @content
	onLeftMouseUp: => 
		@BorderColor = "#ffff00"
		-- routing.navigate "/adventure"
		@navigate "/adventure/#{@game}"

class Adventure extends Node2D
	title: "Adventure"
	class: "flex-col w-full gap-2"
	body: =>
		keys = {}
		for k in pairs games do table.insert keys, k
		table.sort keys
		grid rows: "88px auto 88px", ->
			Header title: @title
			stack class: "flex-col gap-2", ->
				-- for key, game in pairs games do
				for _, key in ipairs keys do
					game = games[key]
					Entry game: key, title: game.title, content: game.description
			Footer!
