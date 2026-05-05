import StackView, TextBlock, ImageView from require "orca.UIKit"

games_config = require "config.games"
import Games from require "model"
import navigate from require "chronicle/views/helpers"

class Adventures extends require "orca.core.widget"
	title: "New Adventure"

	content: =>
		keys = {}
		for k in pairs games_config do table.insert keys, k
		table.sort keys

		-- Load saved games once and build a gameId -> record_id map to avoid
		-- repeated file I/O inside the loop.
		ongoing = Games\findAll!
		record_map = {}
		for g in *ongoing do
			record_map[g.gameId] = record_map[g.gameId] or g.id

		StackView class: "bg-background flex-col gap-3 p-4 overflow-y-scroll h-full", =>
			TextBlock class: "text-xl font-bold text-foreground", "Choose an Adventure"
			for _, key in ipairs keys do
				game = games_config[key]
				has_record = record_map[key] ~= nil
				record_id = record_map[key]

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
