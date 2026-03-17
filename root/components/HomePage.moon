ui = require "orca.UIKit"

HeroSection = require "root.components.homepage.HeroSection"
Transactions = require "root.components.homepage.Transactions"

class HomePage extends ui.StackView
	title: "Overview"
	apply: => "flex-col w-full gap-2"
	body: =>
		HeroSection ".my-2"
		Transactions limit: 5
