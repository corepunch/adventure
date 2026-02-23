routing = require "routing"

import Node2D from require "orca.ui"
import footer from require "assets.constants"

class Footer extends Node2D
	new: (@callback) => super!
	body: =>
		stack class: "bg-neutral-3 w-full h-full justify-evenly", ->
			for item in *footer.links
				selected = routing.get_location! == item.route
				color = selected and "neutral-7" or "neutral-5"
				img ".align-middle-center.text-#{color}" 
					Image: "#{item.imgURL}?width=#{footer.iconSize}&type=mask"
					onLeftMouseUp: -> @callback item.route
