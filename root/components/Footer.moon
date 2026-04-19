routing = require "routing"

import StackView from require "orca.UIKit"
import footer from require "assets.constants"

class Footer extends StackView
	id: "Footer"
	new: (@callback) => super!
	class: "bg-neutral-3 w-full h-full justify-evenly"
	body: =>
		for item in *footer.links
			selected = routing.get_location! == item.route
			color = selected and "neutral-7" or "neutral-5"
			img ".align-middle-center.text-#{color}" 
				Source: "#{item.imgURL}?width=#{footer.iconSize}&type=Mask"
				Stretch: "None"
				LeftMouseUp: -> @callback item.route
				-- LeftMouseUp: @Button_Click

	-- Button_Click: (sender, event) =>
	-- 	-- Handle button click event here
	-- 	print("Button clicked! Owner:", @Name, "Sender:", sender.Name, "Event:", event)