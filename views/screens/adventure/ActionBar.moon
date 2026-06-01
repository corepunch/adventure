import StackView, TextBlock from require "orca.UIKit"

AdventureActionBar = (session, font, on_action) ->
	view = nil

	render_buttons = ->
		for action in *session.actions! do
			command = action.command
			TextBlock {
				class: "bg-surface rounded-3 px-4 py-2 text-base text-foreground text-nowrap"
				FontFamily: font
				LeftButtonUp: ->
					on_action command
					view\rebuild render_buttons if view and view.rebuild
					true
			}, action.label

	view = StackView class: "bg-footer-background px-2 py-2 flex-row gap-2 items-center overflow-x-scroll", ->
		render_buttons!

	view

return AdventureActionBar
