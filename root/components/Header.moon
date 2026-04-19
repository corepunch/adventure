routing = require "routing"

-- import header from require "assets.constants"
ui = require "orca.UIKit"
-- import Users from require "model"

class Header extends ui.Grid
	id: "Header"
	class: "bg-neutral-3 text-2xl p-2"
	Columns: "48px auto"
	body: =>
		img class: "inline-block align-middle mr-4 text-muted-foreground", Source: "assets/icons/follow.svg?width=40&type=Mask"		
		p class: "text-neutral-9 text-2xl font-bold text-center align-middle", @title or "Dungeons & Dragons"
		-- name = Users\getFullName Users\auth!
		-- grid ".bg-muted.px-2", Columns: "auto 100px", ->
		-- 	stack ".align-middle-left.items-center", ->
		-- 		if routing.has_history!
		-- 			img ".align-middle-left.text-muted-foreground"
		-- 				Source: "assets/icons/back.svg?width=#{header.iconSize}&type=Mask"
		-- 				LeftButtonUp: -> routing.go_back!
		-- 		else
		-- 			h5 ".py-2.text-muted-foreground", name
		-- 	stack ".align-middle-right.gap-2", ->
		-- 		for item in *header.links
		-- 			img ".align-middle-center.text-muted-foreground" 
		-- 				Source: "#{item.imgURL}?width=#{header.iconSize}&type=Mask"
		-- 				LeftButtonUp: -> routing.navigate item.route

