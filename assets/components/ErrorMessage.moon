ui = require "orca.UIKit"

class ErrorMessage extends ui.TextBlock
	apply: => "error-message"

	new: (...) =>
		super...
		if type(@error) == 'string'
			@addChild @error
		else
			@addChild @error\json!.message
