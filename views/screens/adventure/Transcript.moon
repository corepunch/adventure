import Node2D, StackView, TextBlock, ImageView from require "orca.UIKit"

class AdventureTranscript
	new: (@session, @font, @background_source) =>
		@console_view = nil

	outgoing: (line) =>
		TextBlock class: "mx-4 my-1 px-4 py-2 text-base text-foreground bg-surface align-right rounded-3", fontFamily: @font, line

	incoming: (line) =>
		TextBlock class: "p-2 text-base text-foreground", fontFamily: @font, line

	add_output: (output) =>
		for line in output\gmatch "[^\n]+" do
			@console_view\addChild @incoming line

	append: (entry) =>
		return unless entry and @console_view
		@console_view\addChild @outgoing entry.cmd if entry.cmd
		@add_output entry.output
		@scroll_to_bottom!

	scroll_to_bottom: =>
		@console_view\SetScrollTop @console_view.ScrollHeight if @console_view

	render: =>
		session = @session
		text_font = @font
		background_source = @background_source
		render_outgoing = (line) ->
			TextBlock class: "mx-4 my-1 px-4 py-2 text-base text-foreground bg-surface align-right rounded-3", fontFamily: text_font, line
		render_incoming = (line) ->
			TextBlock class: "p-2 text-base text-foreground", fontFamily: text_font, line

		@console_view = StackView class: "flex-col overflow-y-scroll h-full py-4", ->
			for _, entry in ipairs session\entries! do
				if entry.cmd
					render_outgoing entry.cmd
				for line in entry.output\gmatch "[^\n]+" do
					render_incoming line

		console_view = @console_view
		console_view.onScrollHeightChanged = -> console_view\SetScrollTop console_view.ScrollHeight

		Node2D class: "bg-background h-full", =>
			ImageView {
				class: "w-full h-full"
				Source: background_source
				Stretch: "UniformToFill"
				Opacity: 0.33
				IgnoreHitTest: true
			}
			@addChild console_view
