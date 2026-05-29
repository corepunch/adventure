Application = require "orca.core.application"
Popup = require "chronicle/views/popups/Popup"

showPopup = (attrs={}) ->
	app = Application.current!
	screen = app and app.screen
	assert screen, "showPopup requires an active screen"

	co, is_main = coroutine.running!
	assert co and not is_main, "showPopup must be called from a coroutine"

	popup = Popup attrs
	popup.on_result = (result) ->
		popup\removeFromParent!
		coroutine.resume co, result

	screen\addChild popup
	return coroutine.yield!

return { :showPopup }
