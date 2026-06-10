ui = require "orca.UIKit"

NAV_ITEMS = {
	{ route: "/",         icon: "assets/icons/home.svg",      label: "Home" }
	{ route: "/games",    icon: "assets/icons/save.svg",      label: "Games" }
	{ route: "/people",   icon: "assets/icons/people.svg",    label: "People" }
	{ route: "/edit",     icon: "assets/icons/edit.svg",      label: "Write" }
	{ route: "/settings", icon: "assets/icons/wallpaper.svg", label: "Settings" }
}

make_header = (title) ->
	ui.StackView class: "app-header", ->
		ui.TextBlock class: "title", title

make_footer = (active_route, navigate) ->
	ui.UniformGrid class: "app-footer", ->
		for item in *NAV_ITEMS
			selected = active_route == item.route
			ui.StackView class: "tab", LeftButtonUp: (-> navigate item.route), ->
				ui.ImageView {
					class: selected and "icon selected" or "icon"
					Source: "#{item.icon}?width=40&type=mask"
				}
				ui.TextBlock class: selected and "label selected" or "label", item.label

make_chrome_footer = (chrome) ->
	ui.StackView class: "chrome-footer", ->
		ui.ImageView
			class: "icon"
			Source: "assets/icons/back.svg?width=24&type=mask"
			LeftButtonUp: chrome.on_back
		ui.Input
			class: "input"
			PlaceholderText: chrome.placeholder or "Enter command..."
			Name: chrome.name or "command"
			Submit: chrome.on_submit

make_placeholder = ->
	ui.StackView class: "empty-route", ->
		ui.TextBlock class: "copy", "No content for this route"

class Default extends require "orca.core.widget"
	content: =>
		inner        = @content_for "inner"
		no_chrome    = @content_for "no_chrome"
		title_slot   = @content_for "title"
		header_slot  = @content_for "header"
		navigate     = @navigate
		active_route = @path or "/"
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
			return ui.Screen { StyleSheet: ui.loadObjectFromCss "assets/globals.css" }, =>
				@addChild (inner or make_placeholder!)

		ui.Screen { StyleSheet: ui.loadObjectFromCss "assets/globals.css" }, ->
			ui.Grid Rows: "32px 52px 1fr 72px 24px", =>
				ui.Node2D class: "app-status-bar"
				@addChild (header_slot or make_header title)
				@addChild (inner or make_placeholder!)
				@addChild footer
				ui.Node2D class: "app-home-indicator"
