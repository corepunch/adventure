import StackView, TextBlock, ImageView from require "orca.UIKit"

games_config = require "config.games"
import Games from require "model"
import navigate from require "chronicle/views/helpers"

class Entry extends require "orca.core.widget"
	content: =>
		StackView {
			class: "bg-surface rounded-3 p-3 flex-row items-center gap-3"
			LeftButtonUp: -> navigate "/adventure", { game: @game }
		}, =>
			ImageView
				class: "align-middle-center"
				Source: "assets/games/#{@game}"
			StackView class: "flex-col flex-1 gap-1", =>
				TextBlock class: "text-base font-bold text-foreground text-nowrap text-ellipsis", @title
				TextBlock class: "text-sm text-foreground-muted", @content

class Adventures extends require "orca.core.widget"
	title: "New Adventure"

	content: =>
		keys = {}
		for k in pairs games_config do table.insert keys, k
		table.sort keys

		StackView class: "bg-background flex-col gap-3 p-4 overflow-y-scroll h-full", =>
			TextBlock class: "text-xl font-bold text-foreground", "Choose an Adventure"
			for _, key in ipairs keys do
				game = games_config[key]
				ongoing = Games\findAll!
				has_record = false
				record_id = nil
				for g in *ongoing do
					if g.gameId == key
						has_record = true
						record_id = g.id
						break

				StackView {
					class: "bg-surface rounded-3 p-4 flex-col gap-2"
					LeftButtonUp: ->
						if has_record
							navigate "/adventure", { game: key, record: record_id }
						else
							navigate "/adventure", { game: key }
				}, =>
					TextBlock class: "text-base font-bold text-foreground", game.title
					TextBlock class: "text-sm text-foreground-muted", game.description
					if has_record
						TextBlock class: "text-xs text-accent", "Continue saved game"
