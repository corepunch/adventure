routing = require "routing"
ui = require "orca.UIKit"
loc = require "orca.localization"
require "html"
Layout = require "root.RootLayout"
page = require "root.pages"

loc.load "assets/localization/en"

import Application from require "routing"

class App extends Application
	@stylesheet "tailwind"
	@stylesheet "assets/globals"

	"/": => Layout page.Adventures
	"/overview": => Layout page.Adventures
	"/adventure/:game": => page.Adventure @params
	"/adventure/:game/:record": => page.Adventure @params
	"/games": => Layout page.OngoingGames

	onAwake: =>
		@navigate '/adventure/zork1'
