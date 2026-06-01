import Node2D, StackView, TextBlock, ImageView from require "orca.UIKit"

AdventureTranscript = (session, font, background_source) ->
	console_view = nil

	outgoing = (line) ->
		TextBlock class: "mx-4 my-1 px-4 py-2 text-base text-foreground bg-muted align-right rounded-3", FontFamily: font, line

	incoming = (line) ->
		TextBlock class: "p-2 text-base text-foreground", FontFamily: font, line

	append = (entry) ->
		return unless entry and console_view
		console_view\addChild outgoing entry.cmd if entry.cmd
		for line in entry.output\gmatch "[^\n]+" do
			console_view\addChild incoming line

	render = ->
		console_view = StackView {
			class: "flex-col overflow-y-scroll h-full py-4"
			onScrollHeightChanged: => @SetScrollTop @ScrollHeight
		}, ->
			for _, entry in ipairs session.entries! do
				if entry.cmd
					outgoing entry.cmd
				for line in entry.output\gmatch "[^\n]+" do
					incoming line

		Node2D class: "bg-background h-full", =>
			ImageView {
				class: "w-full h-full"
				Source: background_source
				Stretch: "UniformToFill"
				Opacity: 0.75
				IgnoreHitTest: true
			}
			@addChild console_view

	{ :append, :render }

return AdventureTranscript
