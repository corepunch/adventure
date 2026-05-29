import StackView, TextBlock, ImageView from require "orca.UIKit"

import Games from require "model"
import navigate from require "chronicle/views/helpers"

class OngoingGames extends require "orca.core.widget"
	title: "Ongoing Games"

	content: =>
		ongoing = Games\ongoing!
		url_for = @url_for

		StackView class: "bg-background flex-col h-full p-4 gap-4 overflow-y-scroll", =>
			TextBlock class: "text-xl font-bold text-foreground", "Saved Games"

			if #ongoing == 0
				TextBlock class: "text-muted-foreground p-4 text-base",
					"No ongoing games. Start a new game from the home screen."
			else
				for game in *ongoing
					StackView {
						class: "bg-surface rounded-3 p-3 flex-row items-center gap-3"
					}, =>
						StackView {
							class: "flex-col flex-1 gap-1"
							LeftButtonUp: -> navigate url_for game
						}, =>
							TextBlock class: "text-base font-bold text-foreground", game.title
							TextBlock class: "text-sm text-muted-foreground",
								"#{game\command_count!} commands played"
						ImageView {
							class: "text-muted-foreground hover:text-destructive"
							Source: "assets/icons/delete.svg?width=28&type=mask"
							LeftButtonUp: ->
								Games\delete game.id
								navigate "/games"
						}
