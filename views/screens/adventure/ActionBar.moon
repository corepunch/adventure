import StackView, TextBlock from require "orca.UIKit"

AdventureActionBar = (session, font, on_action) ->
	view = nil

	render_buttons = ->
		for action in *session.actions! do
			command = action.command
			TextBlock {
				class: "chip"
				FontFamily: font
				LeftButtonUp: ->
					on_action command
					view\rebuild render_buttons if view and view.rebuild
					true
			}, action.label

	view = StackView {
		class: "action-bar"
	}, ->
		render_buttons!

	view

return AdventureActionBar
