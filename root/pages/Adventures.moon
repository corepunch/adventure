import StackView, Node2D from require "orca.ui"
import Header, Footer from require "root.components"
routing = require "routing"
games = require "config.games"
ui = require "orca.ui"

class Entry extends StackView
	class: "flex-col w-full p-2 border-muted-foreground"
	body: =>
		@BorderBottomWidth = 1
		p class: "text-neutral-9 text-2xl", @title
		p class: "text-lg text-neutral-6", @content
	onLeftMouseUp: => 
		@BorderColor = "#ffff00"
		-- routing.navigate "/adventure"
		@navigate "/adventure/#{@game}"

class TabItem extends ui.TextBlock
	class: "text-xl text-primary-600 hover:text-secondary-500"
	onLeftMouseUp: =>
		@postMessage 'NavigateToPage', 
			ui.NavigateToPageArguments URL: @url, TransitionType: "none"

class Adventure extends Node2D
	title: "Select Adventure"
	class: "flex-col w-full gap-2"
	body_: =>
		ui.PageHost ->
			ui.StackView class: "mt-2 mx-2 gap-2 flex-row", ->
				for i = 1, 5 do
					TabItem text: "tab #{i}", url: "/page#{i}"
			ui.Page marginTop: 40, title: "Page1", path: "/page1", -> p "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
			ui.Page marginTop: 40, title: "Page2", path: "/page2", -> p "The quick brown fox jumps over the lazy dog. This pangram contains every letter of the alphabet."
			ui.Page marginTop: 40, title: "Page3", path: "/page3", -> p "Software engineering is the systematic application of engineering approaches to software development."
			ui.Page marginTop: 40, title: "Page4", path: "/page4", -> p "Moonscript is a language that compiles to Lua, combining the power of Lua with a cleaner syntax."
			ui.Page marginTop: 40, title: "Page5", path: "/page5", -> p "Version control systems like Git help teams collaborate and track changes to codebases efficiently."

	body: =>
		keys = {}
		for k in pairs games do table.insert keys, k
		table.sort keys
		grid rows: "32px 48px auto 64px 24px", ->
			Node2D class: 'bg-neutral-3 w-full h-full'
			Header title: @title
			stack class: "flex-col gap-2", ->
				-- for key, game in pairs games do
				for _, key in ipairs keys do
					game = games[key]
					Entry game: key, title: game.title, content: game.description
			Footer!
			Node2D class: 'bg-neutral-3 w-full h-full'
