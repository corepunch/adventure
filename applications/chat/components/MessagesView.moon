ui = require "orca.UIKit"
core = require "orca.core"

import Users, Chats, Messages from require "model"

class MessagesView extends ui.StackView
	new: (@params) => 
		super ".messages",
			ClipChildren: true
			Direction: "Vertical"
			Padding: core.Thickness 16
			OverflowY: "Scroll"
			VerticalAlignment: "Stretch"
			HorizontalAlignment: "Stretch"
		@setTimer 2000

	body: =>
		@user = Users\auth!
		@chat = Chats\find @params.chat
		@last = {}
		for msg in *Messages\findAll @chat
			@bubble msg

	onScrollHeightChanged: () => @SetScrollTop @ScrollHeight

	bubbleClass: (msg) =>
		sender = msg.sender["$id"]
		margin = ".spaced"
		margin = ".tight" if @last.sender and @last.sender["$id"] == sender
		color = ".incoming"
		color = ".outgoing" if @user["$id"] == sender
		@last = msg
		return ".bubble#{margin}#{color}"

	bubble: (msg) => p (@bubbleClass msg), msg.body

	Timer: => 
		return unless @last
		notimezone = (msg) -> msg["$createdAt"]\gsub "%+%d%d:%d%d$", "" if msg
		for msg in *Messages\findAll @chat, notimezone @last
			@addChild @bubble msg
