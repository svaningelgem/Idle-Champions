;Load user settings
global g_UserSettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\..\..\Settings.json" )
global g_KeyMap := {}
global g_SCKeyMap := {}
KeyHelper.BuildVirtualKeysMap(g_KeyMap, g_SCKeyMap)
global g_InputsSent := 0
global g_BrivUserSettingsFromAddons := {}
