ui = require "orca.ui"
games_config = require "config.games"
import Games from require "model"

class GameEntry extends ui.StackView
	class: "flex-col gap-2 mx-2 p-2 bg-neutral-3 rounded w-full"
	body: =>
		@BorderBottomWidth = 1
		config = games_config[@game.gameId] or {title: @game.gameId}
		p class: "text-neutral-9 text-lg font-bold", config.title
		count = @game.commands and #@game.commands or 0
		grid columns: "auto auto", height: 20, ->
			p class: "text-neutral-5", "#{count} commands played"
			p class: "text-neutral-5 align-right", "Score: #{count}"
	onLeftMouseUp: => @navigate "/adventure/#{@game.gameId}"

class OngoingGames extends ui.Node2D
	title: "Ongoing Games"
	class: "flex-col w-full gap-2 my-2"
	body: =>
		ongoing = Games\findAll!
		if #ongoing == 0
			p class: "text-neutral-6 text-lg p-4 text-center", "No ongoing games. Start a new game from the home screen."
		else
			stack id: "gamelist", class: "flex-col gap-2", ->
				for game in *ongoing
					GameEntry id: game.id, game: game
