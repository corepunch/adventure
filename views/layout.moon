import Screen, Grid, UniformGrid, StackView, TextBlock, ImageView, Input, Node2D from require "orca.UIKit"
Widget = require "orca.core.widget"

NAV_ITEMS = {
	{ route: "/",           icon: "assets/icons/home.svg",     label: "Home"   }
	{ route: "/games",      icon: "assets/icons/save.svg",     label: "Games"  }
}

make_header = (title) ->
	StackView class: "bg-header-background px-5 py-3 justify-center", =>
		TextBlock class: "text-2xl font-bold align-center text-nowrap text-ellipsis text-accent-foreground", title

make_footer = (active_route, navigate) ->
	UniformGrid class: "bg-footer-background p-2", =>
		for item in *NAV_ITEMS
			selected = active_route == item.route
			color  = selected and "accent" or "muted-foreground"
			weight = selected and "bold"   or "normal"
			cell = StackView class: "w-full h-full flex-col items-center justify-center gap-1", LeftButtonUp: -> navigate item.route
			cell\addChild ImageView
				class: "align-middle-center text-#{color}"
				Source: "#{item.icon}?width=48&type=mask"
			cell\addChild TextBlock class: "text-xs text-#{color} font-#{weight}", item.label

make_chrome_footer = (chrome) ->
	StackView class: "bg-footer-background flex-row px-4 py-2 gap-2 items-center", =>
		ImageView
			class: "text-muted-foreground"
			Source: "assets/icons/back.svg?width=24&type=mask"
			LeftButtonUp: chrome.on_back
		Input
			class: "bg-surface flex-1 px-4 py-2 rounded text-foreground"
			PlaceholderText: chrome.placeholder or "Enter command..."
			Name: chrome.name or "command"
			Submit: chrome.on_submit

make_placeholder = ->
	StackView class: "bg-background p-6 gap-2", =>
		TextBlock class: "text-base text-muted-foreground", "No content for this route"

class Default extends Widget
	content: =>
		inner        = @content_for "inner"
		no_chrome    = @content_for "no_chrome"
		title_slot   = @content_for "title"
		header_slot  = @content_for "header"
		navigate     = @navigate
		route_val    = @current_route
		active_route = if type(route_val) == "function" then route_val! else route_val or "/"
		view         = @view
		chrome       = view and view.chrome
		title_value  = view and view.title
		title        = if type(title_value) == "function" then title_value! else title_value
		if not title
			title = title_slot

		unless title
			title = if @app_title then @app_title! else "Chronicle"

		footer = if chrome
			make_chrome_footer chrome
		else
			@content_for("footer") or make_footer active_route, navigate

		if no_chrome
			return Screen =>
				@addChild (inner or make_placeholder!)

		Screen ->
			Grid Rows: "32px 52px 1fr 72px 24px", =>
				Node2D class: "bg-header-background"
				@addChild (header_slot or make_header title)
				@addChild (inner or make_placeholder!)
				@addChild footer
				Node2D class: "bg-footer-background"
