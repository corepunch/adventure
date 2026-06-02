ui = require "orca.UIKit"
routing = require "routing"

import MessagesView from require "applications.chat.components"
import header from require "assets.constants"
import Page from require "routing"
import Users, Chats, Messages from require "model"

getPartner = (user, chat) -> 
	for other in *chat.users
		if other["$id"] != user["$id"]
			return other

class Header extends ui.Node2D
	new: (@params, ...) => super...

	body: =>
		chat = Chats\find @params.chat
		partner = Chats\getPartner chat, Users\auth!
		title = Users\getFullName partner
		grid ".chat-header", Columns: "auto auto", ->
			stack ".chat-header-main", ->
				img ".chat-header-back"
					Source: "assets/icons/back.svg?width=#{header.iconSize}&type=Mask"
					LeftButtonUp: -> routing.navigate "/send-money"
				h0 "#title-name.chat-header-title", title
			stack ".chat-header-actions", ->
				for item in *header.links
					img "#control-button.chat-header-action"
						Source: "#{item.imgURL}?width=#{header.iconSize}&type=Mask"
						LeftButtonUp: -> routing.navigate item.route

class ChatLayout extends Page
	new: (@params, ...) =>
		super MessagesView, @params, ...

	title: =>
		chat = Chats\find @params.chat
		partner = Chats\getPartner chat, Users\auth!
		title = Users\getFullName partner

	body: =>
		grid Rows: "64px auto 56px", ->
			@header!
			@content!
			@footer!
	
	header: =>
		Header @params

	footer: =>
		sendMessage = (params) ->
			Input = @findChild 'Input', true
			text = Input.Text
			Input.Text = ""
			Messages\create chat: @params.chat, body: text

		div ".chat-composer", ->
			ui.Input "#msg-input.chat-message-input"
				name: "message"
				placeholderText: ". . ."
				Change: sendMessage
