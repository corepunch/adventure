routing = require "routing"

import Node2D from require "orca.ui"
import footer from require "assets.constants"

class Footer extends Node2D
	body: =>
		stack class: "bg-muted w-full h-full justify-evenly pb-4", ->
			for item in *footer.links
				selected = routing.get_location! == item.route
				color = selected and "foreground" or "muted-foreground"
				img ".align-middle-center.text-#{color}" 
					Image: "#{item.imgURL}?width=#{footer.iconSize}&type=mask"
					onLeftMouseUp: -> routing.navigate item.route
