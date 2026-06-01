import Grid, TextBlock, ImageView from require "orca.UIKit"

AdventureHeader = (title, on_back) ->
	Grid class: "bg-header-background items-center overflow-x-hidden", Columns: "48px 1fr", =>
		ImageView {
			class: "align-middle-center text-accent-foreground"
			Source: "assets/icons/back.svg?width=32&type=mask"
			-- LeftButtonUp: on_back
			LeftButtonUp: ->
				on_back! if on_back
				true
		}
		TextBlock class: "align-middle-left text-lg font-bold text-nowrap text-ellipsis text-accent-foreground", title

return AdventureHeader
