import StackView, TextBlock, ImageView from require "orca.UIKit"

users = {
	"StarWarsFan247", "DarthVibes", "JediMasterLuke", "SithLordOfficial",
	"ForceAwakens42", "GalacticBounty", "RebelScumHQ", "CloneWarsElite",
	"HyperspacePilot", "TheRealYoda",
}

actions = { "chat", "retweet", "like", "bookmark", "share" }

class Tweets extends require "orca.core.widget"
	title: "Tweets"

	content: =>
		StackView class: "bg-background flex-col px-4 gap-4 overflow-y-scroll h-full", =>
			for i = 1, 10
				StackView class: "bg-surface rounded-3 p-3 flex-col gap-2", =>
					StackView class: "flex-row items-center gap-2", =>
						TextBlock class: "text-accent font-bold text-sm", "@#{users[i]}"
						TextBlock class: "text-foreground-muted text-xs", "• 1d"
					TextBlock class: "text-foreground text-sm",
						"The Force is strong with this one. Whether you're Jedi, Sith, or just here for the droids, there's no denying Star Wars shaped generations of fans. What's your favorite moment from the galaxy far, far away?"
					StackView class: "flex-row justify-between", =>
						for action in *actions
							StackView class: "flex-row items-center gap-1", =>
								ImageView
									class: "text-foreground-muted"
									Source: "assets/icons/#{action}.svg?width=18&type=mask"
								TextBlock class: "text-xs text-foreground-muted", "28"
