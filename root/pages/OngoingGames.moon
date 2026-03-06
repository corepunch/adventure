ui = require "orca.ui"
games_config = require "config.games"
import Games from require "model"

class GameEntry extends ui.Grid
	class: "w-full p-2"
	columns: "auto 48px"
	body: =>
		@BorderBottomWidth = 1
		config = games_config[@game.gameId] or {title: @game.gameId}
		stack class: "flex-col flex-1", onLeftMouseUp: ( => @navigate "/adventure/#{@game.gameId}/#{@game.id}"), ->
			p class: "text-neutral-9 text-2xl", config.title
			count = @game.commands and #@game.commands or 0
			p class: "text-lg text-neutral-6", "#{count} commands played"
		img
			class: "align-center align-middle text-neutral-6 hover:text-red-400",
			image: "assets/icons/delete.svg?width=32&type=Mask",
			onLeftMouseUp: =>
				Games\delete @game.id
				@parent\rebuild!

class OngoingGames extends ui.Node2D
	title: "Ongoing Games"
	class: "flex-col w-full gap-2 my-2"
	body: =>
		ongoing = Games\findAll!
		if #ongoing == 0
			p class: "text-neutral-6 p-8 text-lg", "No ongoing games. Start a new game from the home screen."
		else
			stack id: "gamelist", class: "flex-col gap-2", ->
				for game in *ongoing
					GameEntry id: game.id, game: game
