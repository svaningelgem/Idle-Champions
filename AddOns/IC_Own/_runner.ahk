ClearBrivGemFarmStatusMessage()
{
    IC_BrivGemFarm_Component.UpdateStatus("")
}


class Runner {
    StartMiniScripts() {
        g_SF.WriteObjectToJSON(A_LineFile . "\..\LastGUID_Miniscripts.json", g_Miniscripts)
        for k,v in g_Miniscripts
        {
            try
            {
                this.UpdateStatus("Starting Miniscript: " . v)
                Run, %A_AhkPath% "%v%" "%k%"
            }
        }
    }

    StopMiniScripts() {
        for k,v in g_Miniscripts
        {
            this.UpdateStatus("Stopping Miniscript: " . v)
            try
            {
                SharedRunData := ComObjActive(k)
                SharedRunData.Close()
            }
        }
    }

    UpdateGUIDFromLast()
    {
        g_BrivFarm.GemFarmGUID := g_SF.LoadObjectFromJSON(A_LineFile . "\..\LastGUID_BrivGemFarm.json")
    }

    UpdateStatus(msg)
    {
        GuiControl, ICScriptHub:, gBriv_Button_Status, % msg
        SetTimer, ClearBrivGemFarmStatusMessage, -3000
    }

    SwitchToStatsTab() {
        GuiControl, ICScriptHub:Choose, ModronTabControl, Stats
    }

    ConnectToEXE() {
        g_SF.Hwnd := WinExist("ahk_exe " . g_userSettings[ "ExeName"])
        g_SF.Memory.OpenProcessReader()
    }

    StartAddons() {
        for k,v in g_BrivFarmAddonStartFunctions
        {
            this.UpdateStatus("Starting Addon Function: " . v)
            v.Call()
        }
    }

    StopAddons() {
        for k,v in g_BrivFarmAddonStopFunctions
        {
            this.UpdateStatus("Stopping Addon Function: " . v)
            v.Call()
        }
    }

    Briv_Run_Clicked()
    {
        this.SwitchToStatsTab()
        this.TestGameVersion()
        this.UpdateStatus("Starting up")
        this.StopMiniScripts()  ; Stop last run miniscripts (if any)
        this.StartMiniScripts()
        this.ConnectToEXE()
        this.StartAddons()

        g_BrivFarm.GemFarm()
    }

    Briv_Run_Stop_Clicked() {
        this.StopAddons()
        this.StopMiniScripts()
        this.UpdateStatus("Closing Gem Farm")
        try
        {
            g_SF.Close()
            this.UpdateStatus("Gem Farm Stopped")
        }
        catch, err
        {
            this.UpdateStatus("Error stopping gem farm: " . err.Message)
        }
    }

    TestGameVersion()
    {
        gameVersion := g_SF.Memory.ReadGameVersion()
        importsVersion := _MemoryManager.is64bit ? g_ImportsGameVersion64 . g_ImportsGameVersionPostFix64 : g_ImportsGameVersion32 . g_ImportsGameVersionPostFix32
        GuiControl, ICScriptHub: +cF18500, Warning_Imports_Bad,
        if (gameVersion == "")
            GuiControl, ICScriptHub:, Warning_Imports_Bad, % "⚠ Warning: Memory Read Failure. Check for updated Imports."
        else if( gameVersion > 100 AND gameVersion <= 999 AND gameVersion != importsVersion )
            GuiControl, ICScriptHub:, Warning_Imports_Bad, % "⚠ Warning: Game version (" . gameVersion . ") does not match Imports version (" . importsVersion . ")."
        else
            GuiControl, ICScriptHub:, Warning_Imports_Bad, % ""
    }
}
