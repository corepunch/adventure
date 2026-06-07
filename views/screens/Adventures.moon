import StackView, TextBlock, ImageView, Grid from require "orca.UIKit"
import Games, Sessions from require "model"
import navigate from require "chronicle/views/helpers"
Popup = require "chronicle/views/popups/Popup"

class Adventures extends require "orca.core.widget"
	title: "New Adventure"

	content: =>
		StackView {
			class: "adventures-list"
		}, ->
			for game in *Games\catalog! do
				session = Sessions\find_by_game_id game.id
				Grid {
					class: "game-card"
					Columns: "64px auto"
					Spacing: 8
					LeftButtonUp: ->
						ok = @showModal Popup
							title: "Continue saved game?"
							text: "There was a game running already. Do you want to continue it?"
							yes_label: "Yes"
							no_label: "No"
						navigate @url_for session or game if ok == 1
				}, ->
					ImageView {
						class: "cover"
						Source: game\cover_source!
					}
					StackView {
						class: "copy"
					}, ->
						TextBlock { class: "title" }, game.title
						TextBlock class: "description", game.description
						if session
							TextBlock class: "badge", "Continue saved game"
