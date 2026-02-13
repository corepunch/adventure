ui = require "orca.ui"
appwrite = require "appwrite.functions"
openai = require "openai"
json = require "orca.parsers.json"

require 'zilscript'
server = require 'zilscript.runtime'

system = "You are the Dungeon Master in a text-based Dungeons & Dragons adventure. Describe scenes vividly, present choices naturally, and react dynamically to player actions. Keep descriptions immersive but concise."
user = "Let's begin a new D&D adventure. Describe what my character sees as I awaken in a mysterious forest clearing, and ask me what I want to do next."

font = "adventure/fonts/Times New Roman"
files = {
  "zork1/globals.zil",
	"zork1/clock.zil",
  "zork1/parser.zil",
  "zork1/verbs.zil",
  "zork1/actions.zil",
  "zork1/syntax.zil",
  "zork1/dungeon.zil",
  -- "adventure/horror.zil",
  "zork1/main.zil",
}

env = server.create_game_env()

assert(server.init(env))
assert(server.load_zil_files(files, env, {save_lua: true}))

game = server.create_game(env)

highlight = (text) ->
	fmt = "<u>%s</u>"
	for _, dir in ipairs(env.DESCS)
		cap = dir\sub(1,1)\upper! .. dir\sub 2
		text = text\gsub("(%f[%a]#{dir}%f[%A])", (m) -> fmt\format m)
		text = text\gsub("(%f[%a]#{cap}%f[%A])", (m) -> fmt\format m)
	for _, dir in ipairs(env.DIRS)
		cap = dir\sub(1,1)\upper! .. dir\sub 2
		text = text\gsub("(%f[%a]#{dir}%f[%A])", (m) -> fmt\format m)
		text = text\gsub("(%f[%a]#{cap}%f[%A])", (m) -> fmt\format m)
	return text

Message = (line, style) -> 
	if style
		-- p class: "m-2 text-lg #{style}", fontFamily: font, line
		bubble = p class: "mx-4 my-1 p-2 text-lg text-blue-900 bg-blue-300 align-right", fontFamily: font, line
		bubble.BorderRadius = 12
		bubble.BorderBottomRightRadius = 0
		return bubble
	else
		bubble = p class: "mx-4 my-1 p-2 text-lg text-green-900 bg-green-300", fontFamily: font, line
		bubble.BorderRadius = 12
		bubble.BorderBottomLeftRadius = 0
		return bubble

class Controls extends ui.StackView
	new: (@game, @console) => super!
	apply: => "flex-col w-full h-full overflow-y-scroll"

	body: =>
		action = 'm-1 py-1 px-2 text-blue-300 bg-muted hover:bg-primary hover:text-blue-100'
		perform = (button) ->
			input = "#{button.verb} #{button.object or ''}"
			input = input\gsub '-', ' ' -- replace dashes with spaces for better parsing
			@console\addChild Message input\lower!, "text-amber-200"
			scene = @game\resume input
			print("Game response:", scene, button)
			for line in scene\gmatch "[^\n]+" do
				@console\addChild Message line
			-- @rebuild!
			@rebuild!

		Item = (indent, key, verbs, children) ->
			stack class: "ml-#{indent}", ->
				p class: 'm-2 text-green-300', key
				for _, verb in ipairs verbs do
					button class: action, onClick: perform, verb: verb\lower!, object: key, verb\lower!
			for _, t in ipairs children do
				Item indent + 4, table.unpack t

		for _, t in ipairs @game\resume 'room-items' do
			Item 0, table.unpack t

		for _, t in ipairs @game\resume 'room-exits' do
			dir, room = table.unpack t
			stack class: 'flex-row items-center', ->
				button class: action, onClick: perform, verb: "walk", object: dir\lower!, dir\lower!
				p class: 'm-2 text-green-300', room

		stack class: 'flex-row items-center', ->
			button class: action, onClick: perform, verb: "inventory", "Inventory"
			button class: action, onClick: perform, verb: "look", "Look Around"

		p class: 'm-2', @game\resume "inventory"

class ChatInput extends ui.StackView
	new: (@game, @console) => super!
	apply: => "flex-row w-full h-full gap-2 bg-slate-600"
	body: =>
		submit = (cmd) -> 
			@console\addChild Message cmd.Text, "text-amber-200"
			scene = @game\resume cmd.Text
			for line in scene\gmatch "[^\n]+" do
				@console\addChild Message line
			cmd.Text = ""
		d = ui.Input class: "bg-slate-500 hover:bg-slate-400 w-full m-2 p-2 rounded-4", placeholderText: "Print command", onSubmit: submit
		
class Adventure extends ui.Node2D
	title: "Adventure"
	-- apply: => "flex-col w-full gap-2"
	body: =>
		-- response = appwrite.test_openai system, user
		-- json = response\json!
		-- response = {
		-- 	id: "chatcmpl-CZI3yEnk3yLR8yeySTdqTgJgNcKjI"
		-- 	object: "chat.completion"
		-- 	created: 1762526950
		-- 	model: "gpt-4o-mini-2024-07-18"
		-- 	choices: {
		-- 		{
		-- 			index: 0
		-- 			message: {
		-- 				role: "assistant"
		-- 				content: "{\"choices\":[\"Search the clearing for supplies\",\"Examine the unusual trees\",\"Listen for any sounds in the forest\",\"Try to remember how you got here\"],\"scene\":\"You awaken in a serene forest clearing, the sunlight filtering through a vibrant canopy of leaves above. The air is fresh, scented with pine and damp earth. Wildflowers pepper the ground, their colors dancing in the light breeze. A few yards away, a bubbling brook catches your attention, its crystal-clear water tumbling over smooth stones. You feel a sense of tranquility, but also an undercurrent of uncertainty; you cannot recall how you arrived here or what may lie beyond the thicket of trees that encircles the clearing.\"}"
		-- 				refusal: null
		-- 				annotations: {}
		-- 			},
		-- 			logprobs: null
		-- 			finish_reason: "stop"
		-- 		}
		-- 	}
		-- 	usage: {
		-- 		prompt_tokens: 149
		-- 		completion_tokens: 141
		-- 		total_tokens: 290
		-- 		prompt_tokens_details: {
		-- 			cached_tokens: 0
		-- 			audio_tokens: 0
		-- 		}
		-- 		completion_tokens_details: {
		-- 			reasoning_tokens: 0
		-- 			audio_tokens: 0
		-- 			accepted_prediction_tokens: 0
		-- 			rejected_prediction_tokens: 0
		-- 		}
		-- 	}
		-- 	service_tier: "default"
		-- 	system_fingerprint: "fp_560af6e559"
		-- }
		-- desc = json.parse(response.choices[1].message.content)
		-- text = string.gsub(desc.scene, "\\n", "\n")
		-- p class: 'm-2', text
		-- for choice in *desc.choices
		-- 	select = -> @addChild p class: 'm-1', choice
		-- 	ui.Button class: 'm-1 py-1 px-2 text-blue-300 bg-muted hover:bg-primary hover:text-blue-100', onClick: select, choice

		-- response = openai.simple "Translate into russian: App started in Light Mode"
		-- print(response)
		-- print(response\json!.output[2].content[1].text)

		-- response = response\json!
		-- content = json.parse(response.choices[1].message.content)
		-- print "OpenAI response:", content

		console, @controls = nil, nil
		scene = game\resume @input

		-- scene = scene\gsub "\n", "\\n"
		-- response = openai.simple "Translate into russian, keep it concise and natural for D&D game: #{scene}"
		-- scene = response\json!.output[2].content[1].text
		-- print(scene)

		-- if not ok
		-- 	p class: 'm-2', res
		-- 	return
		img class: "w-full h-full", image: "assets/images/room-1", stretch: "UniformToFill", opacity: 0.33
		grid rows: '64px auto 96px', ->
			p class: "w-full h-full bg-slate-600 p-2 text-2xl", fontFamily: font, "Hello, Adventurer!"
			console = stack class: 'flex-col overflow-y-scroll', ->
				-- ui.TextBlock text: 'Hello, ', fontFamily: font, fontSize: 24, ->
				-- 	ui.TextRun text: 'Adventurer', fontWeight: 'bold', fontSize: 32, color: 'text-amber-200'
				-- 	ui.TextRun fontStyle: 'italic', ', welcome to the world of Zork!'
				for line in scene\gmatch "[^\n]+" do
					-- if line == '>' then continue
					Message line
			console.onScrollHeightChanged = () => @setScrollTop @ScrollHeight
			@controls = ChatInput game, console
			-- controls = Controls game, console
