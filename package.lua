Name="chronicle"
-- StartupScreen="root/components/Popup"
StartupScreen="chronicle/App"
WindowWidth=400
WindowHeight=800
ProjectReferences = {
  { Name="applications", Path="applications" },
  { Name="assets", Path="assets" },
  { Name="model", Path="model" },
  { Name="root", Path="root" },
  { Name="config", Path="config" },
  -- External libraries
  { Name="appwrite", Path="lib/appwrite" },
  { Name="html", Path="lib/html" },
  { Name="routing", Path="lib/routing" },
  { Name="openai", Path="lib/openai" },
  { Name="zilscript", Path="lib/zilscript/zilscript" },
  { Name="zork1", Path="lib/zilscript/zork1" },
  { Name="adventure", Path="lib/zilscript/adventure" }
}
SystemMessages = {
  { Message="KeyDown", Key="q", Command="return" },
  { Message="WindowClosed", Command="return" },
  { Message="RequestReload", Command="window:refresh()" }
}
FontLibrary = { Name="fonts", IsExternal=true }
