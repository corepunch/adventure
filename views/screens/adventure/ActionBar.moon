import StackView, TextBlock from require "orca.UIKit"
core = require "orca.core"

AdventureActionBar = (session, font, on_action) ->
	view = nil

	render_buttons = ->
		for action in *session.actions! do
			command = action.command
			TextBlock {
				class: "action-chip"
				BorderRadius: core.CornerRadius 12
				FontSize: 16
				LineHeight: 24
				TextWrapping: "NoWrap"
				FontFamily: font
				LeftButtonUp: ->
					on_action command
					view\rebuild render_buttons if view and view.rebuild
					true
			}, action.label

	view = StackView {
		class: "action-bar"
		Direction: "Horizontal"
		Spacing: 8
		AlignItems: "Center"
		Padding: core.Thickness 8
		OverflowX: "Scroll"
		ClipChildren: true
	}, ->
		render_buttons!

	view

return AdventureActionBar
