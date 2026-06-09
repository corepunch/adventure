import Grid, TextBlock, ImageView from require "orca.UIKit"

AdventureHeader = (title, on_back) ->
	Grid class: "adventure-header", Columns: "32px 1fr", =>
		ImageView {
			class: "back-icon"
			Source: "assets/icons/back.svg?width=32&type=mask"
			-- LeftButtonUp: on_back
			LeftButtonUp: ->
				on_back! if on_back
				true
		}
		TextBlock class: "title", title

return AdventureHeader
