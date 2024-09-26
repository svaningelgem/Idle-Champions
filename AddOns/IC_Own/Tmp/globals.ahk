;Load user settings
global g_BrivUserSettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\BrivGemFarmSettings.json" )
global g_BrivFarm := new IC_BrivGemFarm_Class
g_BrivFarm.GemFarmGUID := g_SF.LoadObjectFromJSON(A_LineFile . "\..\LastGUID_BrivGemFarm.json")
global g_BrivFarmModLoc := A_LineFile . "\..\IC_BrivGemFarm_Mods.ahk"
global g_BrivFarmAddonStartFunctions := {}
global g_BrivFarmAddonStopFunctions := {}
global g_BrivFarmLastRunMiniscripts := g_SF.LoadObjectFromJSON(A_LineFile . "\..\LastGUID_Miniscripts.json")
