import Screen, Grid, UniformGrid, StackView, TextBlock, ImageView, Input, Node2D from require "orca.UIKit"
core = require "orca.core"
filesystem = require "orca.filesystem"
Widget = require "orca.core.widget"

stylesheet = filesystem.loadObjectFromCss "assets/globals.css"

NAV_ITEMS = {
	{ route: "/",           icon: "assets/icons/home.svg",     label: "Home"   }
	{ route: "/games",      icon: "assets/icons/save.svg",     label: "Games"  }
}

make_header = (title) ->
	StackView { class: "app-header", JustifyContent: "Center" }, ->
		TextBlock {
			class: "title"
			FontWeight: "Bold"
			HorizontalAlignment: "Center"
			TextWrapping: "NoWrap"
		}, title

make_footer = (active_route, navigate) ->
	UniformGrid class: "app-footer", ->
		for item in *NAV_ITEMS
			selected = active_route == item.route
			icon_class = selected and "icon selected" or "icon"
			label_class = selected and "label selected" or "label"
			weight = selected and "Bold" or "Normal"
			StackView {
				class: "tab"
				HorizontalAlignment: "Stretch"
				VerticalAlignment: "Stretch"
				Direction: "Vertical"
				AlignItems: "Center"
				JustifyContent: "Center"
				Spacing: 4
				LeftButtonUp: -> navigate item.route
			}, ->
				ImageView {
					class: icon_class
					HorizontalAlignment: "Center"
					VerticalAlignment: "Center"
					Source: "#{item.icon}?width=48&type=mask"
				}
				TextBlock {
					class: label_class
					FontSize: 12
					LineHeight: 16
					FontWeight: weight
				}, item.label

make_chrome_footer = (chrome) ->
	StackView {
		class: "chrome-footer"
		Direction: "Horizontal"
		Spacing: 8
		AlignItems: "Center"
	}, ->
		ImageView
			class: "icon"
			Source: "assets/icons/back.svg?width=24&type=mask"
			LeftButtonUp: chrome.on_back
		Input
			class: "input"
			HorizontalAlignment: "Stretch"
			BorderRadius: core.CornerRadius 8
			PlaceholderText: chrome.placeholder or "Enter command..."
			Name: chrome.name or "command"
			Submit: chrome.on_submit

make_placeholder = ->
	StackView { class: "empty-route", Padding: core.Thickness 24, Spacing: 8 }, ->
		TextBlock { class: "copy", FontSize: 16, LineHeight: 24 }, "No content for this route"

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
			return Screen { StyleSheet: stylesheet }, =>
				@addChild (inner or make_placeholder!)

		Screen { StyleSheet: stylesheet }, ->
			Grid Rows: "32px 52px 1fr 72px 24px", =>
				Node2D class: "app-status-bar"
				@addChild (header_slot or make_header title)
				@addChild (inner or make_placeholder!)
				@addChild footer
				Node2D class: "app-home-indicator"
