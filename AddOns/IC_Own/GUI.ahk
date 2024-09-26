class CombinedGemFarmGUI {
    __New() {
        this.LoadSettings()
    }

    LoadSettings() {

    }

    CreateTab() {
        GUIFunctions.AddTab("Gem Farm")
        Gui, ICScriptHub:Tab, Gem Farm
    }

    AddBrivFarmSection() {
        Gui, ICScriptHub:Add, GroupBox, xp+10 yp+20 w470 h250 vBrivFarm_Group, Briv Farm Settings

        Gui, ICScriptHub:Add, Text, xp+10 yp+20 w120, User Settings:
        Gui, ICScriptHub:Add, Checkbox, vFkeysCheck x+10, Level Champions with Fkeys?
        Gui, ICScriptHub:Add, Checkbox, vDisableDashWaitCheck x15 y+5, Disable Dash Wait?

        Gui, ICScriptHub:Add, GroupBox, x15 y+10 w450 h70, Target haste stacks for next run
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, vNewTargetStacks x25 yp+20 w50, % this.g_BrivUserSettings["TargetStacks"]
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Button, x+5 gBriv_Visit_Byteglow_Speed_Avg_Stacks, Detect Average
        Gui, ICScriptHub:Add, Button, x+3 gBriv_Visit_Byteglow_Speed_Max_Stacks, Detect Max
        Gui, ICScriptHub:Add, Text, x+5 yp+2, (Provided by
        GUIFunctions.UseThemeTextColor("SpecialTextColor1", 600)
        Gui, ICScriptHub:Font, underline
        Gui, ICScriptHub:Add, Text, x+2 gBriv_Visit_Byteglow_Speed_Link, byteglow
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Font, norm
        Gui, ICScriptHub:Add, Text, x+1, )
        Gui, ICScriptHub:Add, Checkbox, x25 y+10 vBrivAutoCalcStatsCheck gBrivAutoDetectStacks_Click, Auto Detect (Ignores detected/byteglow)

        Gui, ICScriptHub:Add, Button, x15 y+20 w50 h50 gBriv_Run_Clicked vBrivGemFarmPlayButton, Play
        Gui, ICScriptHub:Add, Button, x+15 w50 h50 gBriv_Run_Stop_Clicked vBrivGemFarmStopButton, Stop
        Gui, ICScriptHub:Add, Button, x+15 w50 h50 gBriv_Connect_Clicked vBrivGemFarmConnectButton, Connect
        Gui, ICScriptHub:Add, Button, x+15 w50 h50 gBriv_Save_Clicked vBrivGemFarmSaveButton, Save
        Gui, ICScriptHub:Add, Text, x+15 y+-30 w240 h30 vgBriv_Button_Status,
    }

    AddEllywickRNGWaitingRoomSection() {
        Gui, ICScriptHub:Add, GroupBox, x15 y+20 w470 h400 vRNGWR_Group, Ellywick

        Gui, ICScriptHub:Add, GroupBox, xs y+10 w450 h150 vRNGWR_EllywickGemCardsGroup, Ellywick Gem Cards

        Gui, ICScriptHub:Add, CheckBox, xp+10 yp+20 vRNGWR_EllywickGFEnabled gRNGWR_EllywickGFEnabled, Gem farm mode (Ellywick)

        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, w40 x+10 y+10 Limit4 vRNGWR_EllywickGFGemCards gRNGWR_EllywickGFGemCards
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, x+5 h21 0x200 vRNGWR_EllywickGFGemCardsText, # gem cards

        Gui, ICScriptHub:Add, CheckBox, xp-55 y+10 vRNGWR_EllywickGFGemKeepRedrawing gRNGWR_EllywickGFGemKeepRedrawing, Keep redrawing

        Gui, ICScriptHub:Add, Text, xp y+10, Expected results (comma-separated):
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, w200 x+5 vRNGWR_EllywickExpectedResults gRNGWR_EllywickExpectedResults
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, xp y+5 w440, Format: 5 digits per result, digits are: 1:Knight, 2:Moon, 3:Gem, 4:Fates, 5:Flames
        Gui, ICScriptHub:Add, Text, xp y+5 w440, e.g. "00220" means "2 gems & 2 fates", "00003" means 3 flames
    }

    CreateGUI() {
        this.CreateTab()

        this.AddBrivFarmSection()
        this.AddEllywickRNGWaitingRoomSection()

        this.UpdateGUI()
    }

    UpdateBrivSettings(data) {
        GuiControl, ICScriptHub:, FkeysCheck, % data[ "Fkeys" ]
        GuiControl, ICScriptHub:, DisableDashWaitCheck, % data[ "DisableDashWait" ]
        GuiControl, ICScriptHub:, NewTargetStacks, % data[ "TargetStacks" ]
        GuiControl, ICScriptHub:, BrivAutoCalcStatsCheck, % data[ "AutoCalculateBrivStacks" ]
    }

    UpdateEllywickSettings(data) {
        GuiControl, ICScriptHub:, RNGWR_EllywickGFEnabled, % data["EllywickGFEnabled"]
        GuiControl, ICScriptHub:, RNGWR_EllywickGFGemCards, % data["EllywickGFGemCards"]
        GuiControl, ICScriptHub:, RNGWR_EllywickGFGemKeepRedrawing, % data["EllywickGFGemKeepRedrawing"]
        GuiControl, ICScriptHub:, RNGWR_EllywickExpectedResults, % data["EllywickExpectedResults"]
    }

    UpdateGUI() {
        this.UpdateBrivSettings(g_BrivUserSettings)
        this.UpdateEllywickSettings(g_BrivUserSettings)
    }
}