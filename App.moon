html = require "html"
routing = require "routing"
ui = require "orca.ui"
loc = require "orca.localization"
Layout = require "root.RootLayout"
-- page = require "root.components"
page = require "root.pages"

loc.load "assets/localization/en"

import Account from require "model"
import Application from require "routing"
import SearchPage from require "root.pages"

class App extends Application
	@include "applications.users"
	@include "applications.chat"

	@stylesheet require "tailwind"
	@stylesheet "assets/globals.css"

	"/": => Layout page.Adventures
	"/overview": => Layout page.Adventures
	"/adventure/:game": => page.Adventure @params
	"/adventure/:game/:record": => page.Adventure @params
	"/games": => Layout page.OngoingGames
	"/send-money": => Layout page.SendMoney
	"/settings": => Layout page.Settings
	"/tweets": => Layout page.Tweets
	"/new-tweet": => Layout page.NewTweet
	"/user/:user": => Layout page.ContactDetails, @params
	"/transaction/:transaction": => Layout page.TransactionDetails, @params
	"/search": => SearchPage!

	-- onAwake: => 
	-- 	import parse from require "orca.parsers.css"
		-- @navigate '/overview'
		-- @navigate '/adventure/zork1'
		-- routing.navigate '/sign-out'
		-- @navigate '/sign-in' unless pcall Account\auth, Account
