Application = require "orca.core.application"

import Games from require "model"
import navigate from require "chronicle/views/helpers"

AdventureSession = require "chronicle/views/screens/adventure/Session"
AdventureHeader = require "chronicle/views/screens/adventure/Header"
AdventureActionBar = require "chronicle/views/screens/adventure/ActionBar"
AdventureCommandBar = require "chronicle/views/screens/adventure/CommandBar"
AdventureTranscript = require "chronicle/views/screens/adventure/Transcript"
AdventureEmptyState = require "chronicle/views/screens/adventure/EmptyState"

font = "chronicle/fonts/Times New Roman"
background_source = "assets/images/room-1.jpg"
use_action_buttons = false--true

class Adventure extends require "orca.core.widget"
	title: "Adventure"

	content: =>
		app = Application.current false
		data = app and app.nav_data
		game_id = data and data.game
		requested_session_id = data and data.session
		config = game_id and Games\definition game_id

		unless config
			@content_for "title", "Adventure"
			return AdventureEmptyState!

		@content_for "title", config.title
		@content_for "header", AdventureHeader config.title, -> navigate "/"

		session = AdventureSession game_id, requested_session_id, config
		transcript = AdventureTranscript session, font, background_source
		run_command = (command) -> transcript.append session.submit command
		footer = if use_action_buttons
			AdventureActionBar session, font, run_command
		else
			AdventureCommandBar font, run_command

		@content_for "footer", footer
		@content_for "inner", transcript.render!
