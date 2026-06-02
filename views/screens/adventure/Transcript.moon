import Node2D, StackView, TextBlock, ImageView from require "orca.UIKit"
core = require "orca.core"

AdventureTranscript = (session, font, background_source) ->
	console_view = nil

	outgoing = (line) ->
		TextBlock {
			class: "outgoing"
			HorizontalAlignment: "Right"
			BorderRadius: core.CornerRadius 12
			FontFamily: font
		}, line

	incoming = (line) ->
		TextBlock { class: "incoming", FontFamily: font }, line

	append = (entry) ->
		return unless entry and console_view
		console_view\addChild outgoing entry.cmd if entry.cmd
		for line in entry.output\gmatch "[^\n]+" do
			console_view\addChild incoming line

	render = ->
		console_view = StackView {
			class: "log"
			Direction: "Vertical"
			OverflowY: "Scroll"
			ClipChildren: true
			VerticalAlignment: "Stretch"
			onScrollHeightChanged: => @SetScrollTop @ScrollHeight
		}, ->
			for _, entry in ipairs session.entries! do
				if entry.cmd
					outgoing entry.cmd
				for line in entry.output\gmatch "[^\n]+" do
					incoming line

		Node2D { class: "transcript", VerticalAlignment: "Stretch" }, =>
			ImageView {
				class: "background"
				HorizontalAlignment: "Stretch"
				VerticalAlignment: "Stretch"
				Source: background_source
				Stretch: "UniformToFill"
				Opacity: 0.75
				IgnoreHitTest: true
			}
			@addChild console_view

	{ :append, :render }

return AdventureTranscript
