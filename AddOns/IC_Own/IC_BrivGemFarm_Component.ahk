
#include %A_LineFile%\..\GUI.ahk


/*














IC_BrivGemFarm_Component.ResetModFile()

GuiControl, Choose, ICScriptHub:ModronTabControl, BrivGemFarm

ClearBrivGemFarmStatusMessage()
{
    IC_BrivGemFarm_Component.UpdateStatus("")
}

class IC_BrivGemFarm_Component
{
    Briv_Run_Clicked()
    {
        g_SF.WriteObjectToJSON(A_LineFile . "\..\LastGUID_Miniscripts.json", g_Miniscripts)
        for k,v in g_Miniscripts
        {
            try
            {
                this.UpdateStatus("Starting Miniscript: " . v)
                Run, %A_AhkPath% "%v%" "%k%"
            }
        }
        try
        {
            Briv_Connect_Clicked()
            SharedData := ComObjActive(g_BrivFarm.GemFarmGUID)
            SharedData.ShowGui()
        }
        catch
        {
            ;g_BrivGemFarm.GemFarm()
            g_SF.Hwnd := WinExist("ahk_exe " . g_userSettings[ "ExeName"])
            g_SF.Memory.OpenProcessReader()
            scriptLocation := A_LineFile . "\..\IC_BrivGemFarm_Run.ahk"
            GuiControl, ICScriptHub:Choose, ModronTabControl, Stats
            for k,v in g_BrivFarmAddonStartFunctions
            {
                v.Call()
            }
            GuidCreate := ComObjCreate("Scriptlet.TypeLib")
            g_BrivFarm.GemFarmGUID := guid := GuidCreate.Guid
            Run, %A_AhkPath% "%scriptLocation%" "%guid%"
        }
        this.TestGameVersion()
    }

    UpdateGUIDFromLast()
    {
        g_BrivFarm.GemFarmGUID := g_SF.LoadObjectFromJSON(A_LineFile . "\..\LastGUID_BrivGemFarm.json")
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

    Briv_Run_Stop_Clicked()
    {
        for k,v in g_BrivFarmAddonStopFunctions
        {
            this.UpdateStatus("Stopping Addon Function: " . v)
            v.Call()
        }
        for k,v in g_Miniscripts
        {
            this.UpdateStatus("Stopping Miniscript: " . v)
            try
            {
                SharedRunData := ComObjActive(k)
                SharedRunData.Close()
            }
        }
        for k,v in g_BrivFarmLastRunMiniscripts
        {
            try
            {
                SharedRunData := ComObjActive(k)
                SharedRunData.Close()
            }
        }
        this.UpdateStatus("Closing Gem Farm")
        try
        {
            SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
            SharedRunData.Close()
        }
        catch, err
        {
            ; When the Close() function is called "0x800706BE - The remote procedure call failed." is thrown even though the function successfully executes.
            if(err.Message != "0x800706BE - The remote procedure call failed.")
                this.UpdateStatus("Gem Farm not running")
            else
                this.UpdateStatus("Gem Farm Stopped")
        }
    }

    Briv_Connect_Clicked()
    {   
        this.UpdateStatus("Connecting to Gem Farm...") 
        this.UpdateGUIDFromLast()
        Try 
        {
            ComObjActive(g_BrivFarm.GemFarmGUID)
        }
        Catch
        {
            this.UpdateStatus("Gem Farm not running.") 
            return
        }
        g_SF.Hwnd := WinExist("ahk_exe " . g_userSettings[ "ExeName"])
        g_SF.Memory.OpenProcessReader()
        for k,v in g_BrivFarmAddonStartFunctions
        {
            v.Call()
        }
        GuiControl, ICScriptHub:Choose, ModronTabControl, Stats
    }

    ; Checks that current user settings match the currently selected profile's settings.
    TestSettingsMatchProfile(updateStatusMsg)
    {
        global g_BrivUserSettings
        for k,v in this.BrivUserSettingsProfile
        {
            if(!IsObject(v) AND this.BrivUserSettingsProfile[k] != g_BrivUserSettings[k])
            {
                updateStatusMsg := "Session contains changes not yet saved to profile."
                break
            }
            else if (IsObject(v))
            {
                for k1, v1 in v
                {
                    v2 := g_BrivUserSettings[k][k1]
                    if(v[k1] != g_BrivUserSettings[k][k1])
                    {
                        updateStatusMsg := "Session contains changes not yet saved to profile."
                        break
                    }
                }
            }
        }
        return updateStatusMsg
    }

    UpdateStatus(msg)
    {
        GuiControl, ICScriptHub:, gBriv_Button_Status, % msg
        SetTimer, ClearBrivGemFarmStatusMessage,-3000
    }

    Briv_Visit_Byteglow_Speed(speedType := "avg")
    {
        if (!WinExist("ahk_exe " . g_UserSettings[ "ExeName" ]))
        {
            IC_BrivGemFarm_Component.UpdateStatus("Game not running.")
            return
        }
        BrivID := 58
        BrivJumpSlot := 4
        byteglow := new Byteglow_ServerCalls_Class 

        g_SF.Memory.OpenProcessReader()
        gild := g_SF.Memory.ReadHeroLootGild(BrivID, BrivJumpSlot)
        ilvls := Floor(g_SF.Memory.ReadHeroLootEnchant(BrivID, BrivJumpSlot))
        rarity := g_SF.Memory.ReadHeroLootRarityValue(BrivID, BrivJumpSlot)
        if (ilvls == "" OR rarity == "" OR gild == "")
        {
            if(ilvls != "")
            {
                rarity := 1
                gild := 0
            }
            else
            {
                IC_BrivGemFarm_Component.UpdateStatus("Error reading Briv item data from game memory.")
                return
            }
        }
        isMetalBorn := g_SF.IsBrivMetalborn()
        modronReset := g_SF.Memory.GetModronResetArea()
        if (modronReset == "")
        {
            IC_BrivGemFarm_Component.UpdateStatus("Error reading reset area from Modron.")
            return
        }
        else if (modronReset == -1)
        {
            IC_BrivGemFarm_Component.UpdateStatus("Error reading reset area from Modron. (-1)")
            return
        }
        isMetalBorn := isMetalBorn == "" ? 0 : isMetalBorn
        response := byteGlow.CallBrivStacks(gild, ilvls, rarity, isMetalborn, modronReset)
        if(response != "" AND response.Message != "")
        {
            MsgBox, % "Error - " . response.Message
            IC_BrivGemFarm_Component.UpdateStatus("Error retrieving stacks from byteglow.")
        }
        else if(response != "" AND response.error == "")
        {
            if(speedType == "avg")
            {
                GuiControl, ICScriptHub:, NewTargetStacks, % response.stats.stacks.avg
            }
            else if (speedType == "max")
            {
                GuiControl, ICScriptHub:, NewTargetStacks, % response.stats.stacks.max
            }
            IC_BrivGemFarm_Component.UpdateStatus("Target haste stacks updated.")
        }
        else
        {
            IC_BrivGemFarm_Component.UpdateStatus("Error retrieving stacks from byteglow.")
        }
    }
}

#include %A_LineFile%\..\IC_BrivGemFarm_Functions.ahk
*/