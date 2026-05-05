import StackView, TextBlock, ImageView from require "orca.UIKit"

games_config = require "config.games"
import Games from require "model"
import navigate from require "chronicle/views/helpers"

class OngoingGames extends require "orca.core.widget"
	title: "Ongoing Games"

	content: =>
		ongoing = Games\findAll!

		StackView class: "bg-background flex-col h-full p-4 gap-4 overflow-y-scroll", =>
			TextBlock class: "text-xl font-bold text-foreground", "Saved Games"

			if #ongoing == 0
				TextBlock class: "text-foreground-muted p-4 text-base",
					"No ongoing games. Start a new game from the home screen."
			else
				for game in *ongoing
					config = games_config[game.gameId] or { title: game.gameId }
					count  = game.commands and #game.commands or 0
					g = game
					StackView {
						class: "bg-surface rounded-3 p-3 flex-row items-center gap-3"
					}, =>
						StackView {
							class: "flex-col flex-1 gap-1"
							LeftButtonUp: -> navigate "/adventure", { game: g.gameId, record: g.id }
						}, =>
							TextBlock class: "text-base font-bold text-foreground", config.title
							TextBlock class: "text-sm text-foreground-muted",
								"#{count} commands played"
						ImageView {
							class: "text-foreground-muted hover:text-destructive"
							Source: "assets/icons/delete.svg?width=28&type=mask"
							LeftButtonUp: ->
								Games\delete g.id
								navigate "/games"
						}
