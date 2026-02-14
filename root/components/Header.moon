routing = require "routing"

-- import header from require "assets.constants"
import StackView from require "orca.ui"
-- import Users from require "model"

class Header extends StackView
	apply: => "w-full h-full bg-muted p-2 text-2xl items-center pt-8"
	body: =>
		img class: "inline-block align-middle mr-4 text-muted-foreground", image: "assets/icons/back.svg?width=40&type=mask"
		p class: "text-muted-foreground text-2xl", "Dungeons & Dragons"
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

