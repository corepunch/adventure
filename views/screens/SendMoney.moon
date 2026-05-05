import StackView, TextBlock, ImageView from require "orca.UIKit"

import Users, Chats from require "model"
import navigate from require "chronicle/views/helpers"

class SendMoney extends require "orca.core.widget"
	title: "Send Money"

	content: =>
		ok, chats = pcall -> Chats\findAll Users\auth!
		chats = ok and chats or {}

		StackView class: "bg-background flex-col h-full p-4 gap-4 overflow-y-scroll", =>
			TextBlock class: "text-xl font-bold text-foreground", "Contacts"

			for chat in *chats
				partner = Chats\getPartner chat, Users\auth!
				c = chat
				StackView {
					class: "bg-surface rounded-3 px-4 py-3 flex-row items-center gap-3"
					LeftButtonUp: -> navigate "/chat", { chat: c["$id"] }
				}, =>
					ImageView
						class: "align-middle-center"
						Source: "https://picsum.photos/48"
					StackView class: "flex-col gap-1", =>
						TextBlock class: "text-base font-bold text-foreground",
							Users\getFullName partner
						TextBlock class: "text-xs text-foreground-muted",
							"@" .. partner["$id"]
