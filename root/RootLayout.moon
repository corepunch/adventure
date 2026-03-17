import navigate, Page from require "routing"
import Header, Footer from require "root.components"
import Users from require "model"
import header from require "assets.constants"
ui = require "orca.UIKit"

class RootLayout extends Page
	body: =>
		grid Rows: "32px 48px auto 64px 24px", ->
			ui.Node2D class: 'bg-neutral-3 w-full h-full'
			@header!
			@content!
			@footer!
			ui.Node2D class: 'bg-neutral-3 w-full h-full'

	titleString: => @view.title or "Page Title"
	navigate: (route) => navigate route
	footer: => Footer @navigate
	header: => Header title: @titleString!
		-- routing = require "routing"
		-- name = Users\getFullName Users\auth!
		-- h0 ".px-2.w-full.h-full", @title!

		-- grid ".bg-muted.px-2", Columns: "auto 100px", ->
		-- 	stack ".align-middle-left.items-center", ->
		-- 		if routing.has_history!
		-- 			img ".align-middle-left.text-muted-foreground"
		-- 				Image: "assets/icons/back.svg?width=#{header.iconSize}&type=Mask"
		-- 				onLeftMouseUp: -> routing.go_back!
		-- 		else
		-- 			h5 ".py-2.text-muted-foreground", name
		-- 	stack ".align-middle-right.gap-2", ->
		-- 		for item in *header.links
		-- 			img ".align-middle-center.text-muted-foreground" 
		-- 				Image: "#{item.imgURL}?width=#{header.iconSize}&type=Mask"
		-- 				onLeftMouseUp: -> routing.navigate item.route

