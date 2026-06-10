import StackView, TextBlock, ImageView from require "orca.UIKit"

import Sessions from require "model"

class OngoingGames extends require "orca.core.widget"
	title: "Ongoing Games"

	content: =>
		ongoing = Sessions\ongoing!

		StackView {
			class: "saved-games-screen"
		}, ->
			TextBlock { class: "heading" }, "Saved Games"

			if #ongoing == 0
				TextBlock { class: "empty" },
					"No ongoing games. Start a new game from the home screen."
			else
				for game in *ongoing
					StackView {
						class: "saved-game-row"
					}, ->
						StackView {
							class: "copy"
							LeftButtonUp: -> @navigate @url_for game
						}, ->
							TextBlock { class: "title" }, game.title
							TextBlock class: "description",
								"#{game\command_count!} commands played"
						ImageView {
							class: "delete"
							Source: "assets/icons/delete.svg?width=28&type=mask"
							LeftButtonUp: ->
								Sessions\delete game.id
								@navigate "/games"
						}
