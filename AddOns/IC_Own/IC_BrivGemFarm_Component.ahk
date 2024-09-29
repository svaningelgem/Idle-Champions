
#include %A_LineFile%\..\GUI.ahk


/*














GuiControl, Choose, ICScriptHub:ModronTabControl, BrivGemFarm


class IC_BrivGemFarm_Component
{


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