RootLayout = require "root.RootLayout"
ui = require "orca.UIKit"

import Search from require "root.components"
import header from require "assets.constants"

class SearchPage extends RootLayout
	new: => super Search

	header: =>
		grid ".px-2", Columns: "auto #{header.iconSize+4}px", ->
			ui.Input ".align-middle.input",
				Name: "Search"
				PlaceholderText: "Search users"
				Char: (search) -> @contentView\performSearch search
			img ".align-middle-right.text-muted-foreground"
				Source: "assets/icons/logout.svg?width=#{header.iconSize}&type=Mask"
				LeftButtonUp: -> routing.go_back!
