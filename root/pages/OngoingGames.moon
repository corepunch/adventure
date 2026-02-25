ui = require "orca.ui"
games_config = require "config.games"
import Games from require "model"

class GameEntry extends ui.StackView
	class: "flex-row w-full p-2 items-center"
	body: =>
		@BorderBottomWidth = 1
		config = games_config[@gameId] or {title: @gameId}
		stack class: "flex-col flex-1", onLeftMouseUp: => @navigate "/adventure/#{@gameId}/#{@id}", ->
			p class: "text-neutral-9 text-2xl", config.title
			count = @commands and #@commands or 0
			p class: "text-lg text-neutral-6", "#{count} commands played"
		img
			class: "mx-2 text-neutral-6 hover:text-red-400",
			image: "assets/icons/delete.svg?width=32&type=mask",
			onLeftMouseUp: =>
				Games\delete @id
				@parent\rebuild!

class OngoingGames extends ui.Node2D
	title: "Ongoing Games"
	class: "flex-col w-full gap-2"
	body: =>
		ongoing = Games\findAll!
		if #ongoing == 0
			p class: "text-neutral-6 text-lg p-4 text-center", "No ongoing games. Start a new game from the home screen."
		else
			stack class: "flex-col gap-2", ->
				for game in *ongoing
					GameEntry id: game.id, gameId: game.gameId, commands: game.commands
