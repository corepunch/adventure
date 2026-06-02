import StackView, TextBlock, ImageView from require "orca.UIKit"
core = require "orca.core"

import Sessions from require "model"
import navigate from require "chronicle/views/helpers"

class OngoingGames extends require "orca.core.widget"
	title: "Ongoing Games"

	content: =>
		ongoing = Sessions\ongoing!

		StackView {
			class: "saved-games-screen"
			Direction: "Vertical"
			VerticalAlignment: "Stretch"
			Spacing: 16
			OverflowY: "Scroll"
			ClipChildren: true
		}, ->
			TextBlock { class: "screen-title", FontWeight: "Bold" }, "Saved Games"

			if #ongoing == 0
				TextBlock { class: "muted-copy", Padding: core.Thickness 16, FontSize: 16, LineHeight: 24 },
					"No ongoing games. Start a new game from the home screen."
			else
				for game in *ongoing
					StackView {
						class: "saved-game-row"
						Direction: "Horizontal"
						AlignItems: "Center"
						Spacing: 12
						BorderRadius: core.CornerRadius 12
					}, ->
						StackView {
							class: "saved-game-copy"
							Direction: "Vertical"
							HorizontalAlignment: "Stretch"
							Spacing: 4
							LeftButtonUp: -> navigate @url_for game
						}, ->
							TextBlock { class: "saved-game-title", FontWeight: "Bold" }, game.title
							TextBlock class: "game-description",
								"#{game\command_count!} commands played"
						ImageView {
							class: "delete-button"
							Source: "assets/icons/delete.svg?width=28&type=mask"
							LeftButtonUp: ->
								Sessions\delete game.id
								navigate "/games"
						}
