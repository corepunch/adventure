import Grid, TextBlock, ImageView from require "orca.UIKit"

AdventureHeader = (title, on_back) ->
	Grid {
		class: "adventure-header"
		Columns: "48px 1fr"
		OverflowX: "Hidden"
		ClipChildren: true
	}, =>
		ImageView {
			class: "adventure-back-icon"
			HorizontalAlignment: "Center"
			VerticalAlignment: "Center"
			Source: "assets/icons/back.svg?width=32&type=mask"
			-- LeftButtonUp: on_back
			LeftButtonUp: ->
				on_back! if on_back
				true
		}
		TextBlock {
			class: "adventure-title"
			HorizontalAlignment: "Left"
			VerticalAlignment: "Center"
			FontSize: 18
			LineHeight: 28
			FontWeight: "Bold"
			TextWrapping: "NoWrap"
			TextOverflow: "Ellipsis"
		}, title

return AdventureHeader
