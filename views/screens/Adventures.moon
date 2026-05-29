import StackView, TextBlock, ImageView, Grid from require "orca.UIKit"

core = require "core"
import Games from require "model"
import navigate from require "chronicle/views/helpers"

class Adventures extends require "orca.core.widget"
	title: "New Adventure"

	content: =>
		url_for = @url_for

		launch_game = (game, saved_game=nil) ->
			navigate url_for saved_game or game

		StackView class: "bg-background flex-col gap-3 overflow-y-scroll h-full", ->
			for game in *Games\catalog! do
				saved_game = Games\find_by_game_id game.id
				launch = saved_game or game
				Grid {
					class: "bg-surface rounded-lg p-2 gap-2 items-center"
					Columns: "64px auto"
					LeftButtonUp: ->
						if saved_game
							ok = core.showPopup
								title: "Continue saved game?"
								text: "There was a game running already. Do you want to continue it?"
								yes_label: "Yes"
								no_label: "No"
							return unless ok == 1
						launch_game game, saved_game
				}, ->
					ImageView
						class: "rounded-2"
						Source: launch\cover_source!
					StackView class: "flex-col flex-1 gap-1", ->
						TextBlock class: "text-base font-bold text-foreground", launch.title
						TextBlock class: "text-sm text-muted-foreground", launch.description
						if saved_game
							TextBlock class: "text-xs text-accent", "Continue saved game"
