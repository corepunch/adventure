import Application from require "routing"

chat = require "applications.chat.layouts.ChatLayout"

class ChatApplication extends Application
	"/chat/:chat": (req) => chat req.params
