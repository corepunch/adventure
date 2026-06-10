ui = require "orca.UIKit"

NAV_ITEMS = {
	{ route: "/",         icon: "assets/icons/home.svg",      label: "Home" }
	{ route: "/games",    icon: "assets/icons/save.svg",      label: "Games" }
	{ route: "/people",   icon: "assets/icons/people.svg",    label: "People" }
	{ route: "/edit",     icon: "assets/icons/edit.svg",      label: "Write" }
	{ route: "/settings", icon: "assets/icons/wallpaper.svg", label: "Settings" }
}

class Default extends require "orca.core.widget"
	stylesheet: => ui.loadObjectFromCss "assets/globals.css"

	header: (title=nil) =>
		title = @resolved_title! unless title
		ui.StackView class: "app-header", ->
			ui.TextBlock class: "title", title

	footer_tabs: =>
		ui.UniformGrid class: "app-footer", ->
			for item in *NAV_ITEMS
				selected = (@path or "/") == item.route
				ui.StackView class: "tab", LeftButtonUp: (-> @navigate item.route), ->
					ui.ImageView {
						class: selected and "icon selected" or "icon"
						Source: "#{item.icon}?width=40&type=mask"
					}
					ui.TextBlock class: selected and "label selected" or "label", item.label

	chrome_footer: (chrome) =>
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

	placeholder: =>
		ui.StackView class: "empty-route", ->
			ui.TextBlock class: "copy", "No content for this route"

	resolved_title: =>
		title = @view and @view.title
		title = title! if type(title) == "function"
		title or @content_for("title") or (@app_title and @app_title!) or "Chronicle"

	resolved_inner: => @content_for("inner") or @placeholder!

	resolved_header: => @content_for("header") or @header!

	resolved_footer: =>
		chrome = @view and @view.chrome
		return @chrome_footer chrome if chrome
		@content_for("footer") or @footer_tabs!

	content: =>
		if @content_for "no_chrome"
			return ui.Screen { StyleSheet: @stylesheet! }, (screen) -> screen\addChild @resolved_inner!
		ui.Screen { StyleSheet: @stylesheet! }, -> 
			ui.Grid Rows: "32px 52px 1fr 72px 24px", (grid) ->
				ui.Node2D class: "app-status-bar"
				-- inner is often prebuilt before the grid callback runs, so returning it as an expression 
				-- does not parent it to the current host. I’m patching content/main to use the host callback 
				-- argument (host) and only use host\addChild where it is actually necessary for those 
				-- prebuilt nodes.
				grid\addChild @resolved_header!
				grid\addChild @resolved_inner!
				grid\addChild @resolved_footer!
				ui.Node2D class: "app-home-indicator"

