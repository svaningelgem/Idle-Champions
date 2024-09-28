ReloadBrivGemFarmSettings()
{
    if ( g_BrivUserSettings[ "Fkeys" ] == "" )
        g_BrivUserSettings[ "Fkeys" ] := 1
    if ( g_BrivUserSettings[ "StackFailRecovery" ] == "" )
        g_BrivUserSettings[ "StackFailRecovery" ] := 1
    if (g_BrivUserSettings[ "TargetStacks" ] == "")
        g_BrivUserSettings[ "TargetStacks" ] := 0
    if (g_BrivUserSettings[ "DashWaitBuffer" ] == "")
        g_BrivUserSettings[ "DashWaitBuffer" ] := 30
    if ( g_BrivUserSettings[ "WindowXPosition" ] == "" )
        g_BrivUserSettings[ "WindowXPosition" ] := 0
    if ( g_BrivUserSettings[ "WindowYPosition" ] == "" )
        g_BrivUserSettings[ "WindowYPosition" ] := 0
    if ( g_BrivUserSettings[ "HiddenFarmWindow" ] == "" )
        g_BrivUserSettings[ "HiddenFarmWindow" ] := 0
    if ( g_BrivUserSettings[ "DoChestsContinuous" ] == "" )
        g_BrivUserSettings[ "DoChestsContinuous" ] := 0
    if ( g_BrivUserSettings[ "ResetZoneBuffer" ] == "" )
        g_BrivUserSettings[ "ResetZoneBuffer" ] := 41
    if (g_BrivUserSettings[ "IgnoreBrivHaste" ] == "" )
        g_BrivUserSettings[ "IgnoreBrivHaste" ] := 0
    if ( g_BrivUserSettings[ "ForceOfflineGemThreshold" ] == "" )
        g_BrivUserSettings[ "ForceOfflineGemThreshold" ] := 0
    if ( g_BrivUserSettings[ "ForceOfflineRunThreshold" ] == "" )
        g_BrivUserSettings[ "ForceOfflineRunThreshold" ] := 0
    if ( g_BrivUserSettings[ "ManualBrivJumpValue" ] == "" )
        g_BrivUserSettings[ "ManualBrivJumpValue" ] := 0
    if ( g_BrivUserSettings[ "BrivJumpBuffer" ] == "" )
        g_BrivUserSettings[ "BrivJumpBuffer" ] := 0
    if ( g_BrivUserSettings[ "DisableDashWait" ] == "" )
        g_BrivUserSettings[ "DisableDashWait" ] := false
    if ( g_BrivUserSettings[ "RestoreLastWindowOnGameOpen" ] == "" )
        g_BrivUserSettings[ "RestoreLastWindowOnGameOpen" ] := true
    if ( g_BrivUserSettings[ "AutoCalculateBrivStacks" ] == "" )
        g_BrivUserSettings[ "AutoCalculateBrivStacks" ] := False
    if (g_BrivUserSettings[ "AutoCalculateWorstCase" ] == "" )
        g_BrivUserSettings[ "AutoCalculateWorstCase" ] := true
    if ( g_BrivUserSettings[ "PreferredBrivJumpZones" ] == "")
	    g_BrivUserSettings[ "PreferredBrivJumpZones" ] := [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

    if ( g_BrivUserSettings["EllywickGFEnabled"] == "" )
        g_BrivUserSettings["EllywickGFEnabled"] := true
    if ( g_BrivUserSettings["EllywickGFGemKeepRedrawing"] == "" )
        g_BrivUserSettings["EllywickGFGemKeepRedrawing"] := true
    if ( g_BrivUserSettings["EllywickExpectedResults"] == "" )
        g_BrivUserSettings["EllywickExpectedResults"] := "00220,00300"

    g_SF.WriteObjectToJSON( A_LineFile . "\..\BrivGemFarmSettings.json" , g_BrivUserSettings )
}


global g_BrivUserSettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\BrivGemFarmSettings.json" )
ReloadBrivGemFarmSettings()
