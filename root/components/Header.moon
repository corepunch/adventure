routing = require "routing"

-- import header from require "assets.constants"
import StackView from require "orca.ui"
-- import Users from require "model"

class Header extends StackView
	apply: => "w-full h-full bg-slate-600 p-2 text-2xl items-center"
	body: =>
		img class: "inline-block align-middle mr-4 text-green-300", image: "assets/icons/back.svg?width=48&type=mask"
			-- p class: "inline-block align-middle text-green-300", "Dungeons & Dragons"
		p class: "text-green-300 text-xl", "Mysterious Forest Clearing"
		-- name = Users\getFullName Users\auth!
		-- grid ".bg-muted.px-2", Columns: "auto 100px", ->
		-- 	stack ".align-middle-left.items-center", ->
		-- 		if routing.has_history!
		-- 			img ".align-middle-left.text-muted-foreground"
		-- 				Image: "assets/icons/back.svg?width=#{header.iconSize}&type=mask"
		-- 				onLeftMouseUp: -> routing.go_back!
		-- 		else
		-- 			h5 ".py-2.text-muted-foreground", name
		-- 	stack ".align-middle-right.gap-2", ->
		-- 		for item in *header.links
		-- 			img ".align-middle-center.text-muted-foreground" 
		-- 				Image: "#{item.imgURL}?width=#{header.iconSize}&type=mask"
		-- 				onLeftMouseUp: -> routing.navigate item.route

