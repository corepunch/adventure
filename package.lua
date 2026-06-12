Name = "chronicle"
StartupViewController = "chronicle/App"
StartupRoute = "/"
WindowWidth = 400
WindowHeight = 800
ProjectReferences = {
  { Name = "views",       Path = "views"                    },
  { Name = "assets",      Path = "assets"                   },
  { Name = "model",       Path = "model"                    },
  { Name = "config",      Path = "config"                   },
  { Name = "appwrite",    Path = "lib/appwrite"             },
  { Name = "openai",      Path = "lib/openai"               },
  { Name = "zilscript",   Path = "lib/zilscript/zilscript"  },
  { Name = "zork1",       Path = "lib/zilscript/zork1"      },
  { Name = "adventure",   Path = "lib/zilscript/adventure"  },
}
SystemMessages = {
  { Message = "KeyDown",      Key = "q", Command = "return"           },
  { Message = "WindowClosed",            Command = "return"           },
  { Message = "RequestReload",           Command = "window:refresh()" },
}
FontLibrary = { Name = "fonts", IsExternal = true }
ThemeLibrary = {
	{ Key = "background", Value = "#FFFFFF" },
	{ Key = "foreground", Value = "#0B0F1A" },
	{ Key = "accent", Value = "#345EC7" },
	{ Key = "accent-foreground", Value = "#FFFFFF" },
	{ Key = "accent-background", Value = "#C5CDDC" },
	-- { Key = "accent-hover", Value = "#D67949" },
	{ Key = "muted-foreground", Value = "#6B7280" },
	{ Key = "very-muted-foreground", Value = "#96A0B4" },
	{ Key = "border", Value = "#E3E8F0" },
	{ Key = "danger", Value = "#D63939" },
	{ Key = "warning", Value = "#FFB620" },
	{ Key = "message-incoming", Value = "#0369A1" },
	{ Key = "message-outgoing", Value = "#C2410C" },
}
