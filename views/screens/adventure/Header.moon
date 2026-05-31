import Grid, TextBlock, ImageView from require "orca.UIKit"

class AdventureHeader
	new: (@title, @font, @on_back) =>

	render: =>
		title = @title
		text_font = @font
		on_back = @on_back

		Grid {
			class: "bg-header-background items-center overflow-x-hidden"
			Columns: "80px 1fr"
		}, =>
			ImageView {
				class: "align-middle-center text-accent-foreground"
				Source: "assets/icons/back.svg?width=32&type=mask"
				LeftButtonUp: on_back
			}
			TextBlock {
				class: "w-full h-full align-middle-left text-base font-bold text-left text-nowrap text-ellipsis text-accent-foreground pr-5"
				fontFamily: text_font
			}, title
