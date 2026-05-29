import StackView, TextBlock, ImageView, Grid from require "orca.UIKit"
import Games, Sessions from require "model"
import navigate from require "chronicle/views/helpers"
Popup = require "chronicle/views/popups/Popup"

class Adventures extends require "orca.core.widget"
	title: "New Adventure"

	content: =>
		StackView class: "bg-background flex-col gap-3 overflow-y-scroll h-full", ->
			for game in *Games\catalog! do
				session = Sessions\find_by_game_id game.id
				Grid {
					class: "bg-surface rounded-lg p-2 gap-2 items-center"
					Columns: "64px auto"
					LeftButtonUp: ->
						-- if session
						ok = @showModal Popup
							title: "Continue saved game?"
							text: "There was a game running already. Do you want to continue it?"
							yes_label: "Yes"
							no_label: "No"
						return unless ok == 1
						print('navigating to', @url_for session or game)
						navigate @url_for session or game
				}, ->
					ImageView class: "rounded-2", Source: game\cover_source!
					StackView class: "flex-col flex-1 gap-1", ->
						TextBlock class: "text-base font-bold text-foreground", game.title
						TextBlock class: "text-sm text-muted-foreground", game.description
						if session
							TextBlock class: "text-xs text-accent", "Continue saved game"
