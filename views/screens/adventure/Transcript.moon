import Node2D, StackView, TextBlock, ImageView from require "orca.UIKit"
	
AdventureTranscript = (session, background_source) ->
	console_view = nil

	outgoing = (line) ->
		TextBlock class: "outgoing", line

	incoming = (line) ->
		TextBlock class: "incoming", line

	append = (entry) ->
		return unless entry and console_view
		console_view\addChild outgoing entry.cmd if entry.cmd
		for line in entry.output\gmatch "[^\n]+" do
			console_view\addChild incoming line

	render = ->
		console_view = StackView {
			class: "log"
			onScrollHeightChanged: => @SetScrollTop @ScrollHeight
		}, ->
			for _, entry in ipairs session.entries! do
				if entry.cmd
					outgoing entry.cmd
				for line in entry.output\gmatch "[^\n]+" do
					incoming line

		Node2D class: "transcript", =>
			-- ImageView {
			-- 	class: "background"
			-- 	Source: background_source
			-- 	VerticalAlignment: "Stretch"
			-- 	Stretch: "UniformToFill"
			-- 	ForegroundColor: "#FFFFFFFF"
			-- 	IgnoreHitTest: true
			-- }
			@addChild console_view

	{ :append, :render }

return AdventureTranscript
