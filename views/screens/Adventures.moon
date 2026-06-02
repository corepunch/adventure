import StackView, TextBlock, ImageView, Grid from require "orca.UIKit"
core = require "orca.core"
import Games, Sessions from require "model"
import navigate from require "chronicle/views/helpers"
Popup = require "chronicle/views/popups/Popup"

class Adventures extends require "orca.core.widget"
	title: "New Adventure"

	content: =>
		StackView {
			class: "adventures-list"
			Direction: "Vertical"
			Spacing: 12
			OverflowY: "Scroll"
			ClipChildren: true
			VerticalAlignment: "Stretch"
		}, ->
			for game in *Games\catalog! do
				session = Sessions\find_by_game_id game.id
				Grid {
					class: "game-card"
					Columns: "64px auto"
					Spacing: 8
					BorderRadius: core.CornerRadius 8
					LeftButtonUp: ->
						ok = @showModal Popup
							title: "Continue saved game?"
							text: "There was a game running already. Do you want to continue it?"
							yes_label: "Yes"
							no_label: "No"
						navigate @url_for session or game if ok == 1
				}, ->
					ImageView {
						class: "game-cover"
						BorderRadius: core.CornerRadius 8
						Source: game\cover_source!
					}
					StackView {
						class: "game-copy"
						Direction: "Vertical"
						HorizontalAlignment: "Stretch"
						Spacing: 4
					}, ->
						TextBlock { class: "game-title", FontWeight: "Bold" }, game.title
						TextBlock class: "game-description", game.description
						if session
							TextBlock class: "game-badge", "Continue saved game"
