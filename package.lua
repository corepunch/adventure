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
