Application = require "orca.core.application"
import TextBlock, StackView, ImageView, Node2D from require "orca.UIKit"
import Games from require "model"

AdventureSession = require "chronicle/views/screens/adventure/Session"
AdventureHeader = require "chronicle/views/screens/adventure/Header"
AdventureActionBar = require "chronicle/views/screens/adventure/ActionBar"
AdventureCommandBar = require "chronicle/views/screens/adventure/CommandBar"
AdventureTranscript = require "chronicle/views/screens/adventure/Transcript"
AdventureEmptyState = require "chronicle/views/screens/adventure/EmptyState"

-- background_source = "assets/images/room-1.jpg"
use_action_buttons = false--true

class Adventure extends require "orca.core.widget"
	title: "Adventure"

	content: =>
		game = Games\definition @params.game

		unless game
			@content_for "title", "Adventure"
			return AdventureEmptyState!

		@content_for "title", game.title
		@content_for "header", AdventureHeader game.title, -> @navigate "/"

		session = AdventureSession @params.game, @params.session, game
		transcript = AdventureTranscript session--, background_source
		run_command = (command) -> transcript.append session.submit command
		footer = if use_action_buttons
			AdventureActionBar session, run_command
		else
			AdventureCommandBar run_command

		@content_for "footer", footer
		-- @content_for "inner", transcript.render!
		@content_for "inner", StackView class: "transcript", -> 
			transcript.render!
			for _, item in ipairs { "Open book", "Turn on lamp", "Pick up key" }
				TextBlock class: "suggestion", item
			-- TextBlock class: "disclaimer", "This is a work in progress. Save your game often, and expect things to break!"
