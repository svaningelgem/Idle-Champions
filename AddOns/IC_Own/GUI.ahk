#include %A_LineFile%\..\..\..\SharedFunctions\SH_GUIFunctions.ahk

g_TabControlHeight := Max(g_TabControlHeight, 500)
g_TabControlWidth := Max(g_TabControlWidth, 485)

global g_LeftAlign
global g_DownAlign


class CombinedGemFarmGUI {
    ySpacing := 10

    __New() {
        ReloadBrivGemFarmSettings()
    }

    CreateTab(tabName) {
        GUIFunctions.AddTab(tabName)
        Gui, ICScriptHub:Tab, %tabName%
    }

    AddBrivFarmSection() {
        global

        GUIFunctions.UseThemeTextColor()

        Gui, ICScriptHub:Add, Button, x15 y+10 w50 h50 gBriv_Start_Clicked vBrivGemFarmPlayButton, Play
        Gui, ICScriptHub:Add, Button, x+15 w50 h50 gBriv_Stop_Clicked vBrivGemFarmStopButton, Stop
        Gui, ICScriptHub:Add, Text, x+15 y-10 w240 h30 vgBriv_Button_Status,

        Gui, ICScriptHub:Add, GroupBox, xs+10 y+110 w433 h66 vBrivFarm_Group Section, Briv Farm Settings

        Gui, ICScriptHub:Add, Checkbox, xs+10 ys+20 vFkeys gControlChanged, Level Champions with Fkeys?
        Gui, ICScriptHub:Add, Checkbox, xs+10 y+5 vDisableDashWait gControlChanged, Disable Dash Wait?
    }

    AddEllywickRNGWaitingRoomSection() {
        global

        GUIFunctions.UseThemeTextColor()

        Gui, ICScriptHub:Add, GroupBox, x15 y+30 w432 h155 vEllywick_Group Section, Ellywick

        Gui, ICScriptHub:Add, CheckBox, xs+10 yp+20 vEllywickGFEnabled gControlChanged, Enable Ellywick (gem farming)
        Gui, ICScriptHub:Add, CheckBox, xs+10 y+5 vEllywickGFGemKeepRedrawing gControlChanged, Keep redrawing

        Gui, ICScriptHub:Add, Text, xs+10 y+10, Expected results (comma-separated):

        Gui, ICScriptHub:Add, Text, xs+20 y+5 w440, Format: 5 digits per result, digits are: 1:Knight, 2:Moon, 3:Gem, 4:Fates, 5:Flames
        Gui, ICScriptHub:Add, Text, xs+20 y+5 w440, e.g. "00220" means "2 gems & 2 fates", "00003" means 3 flames
        Gui, ICScriptHub:Add, Edit, xs+10 w400 y+10 vEllywickExpectedResults gControlChanged
    }

    addStats() {
        global

        Gui, ICSCriptHub:Add, Button, x+5 gReset_Briv_Farm_Stats vReset_Briv_Farm_Stats_Button, Reset Stats
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, Text, vWarning_Imports_Bad x+7 y+-17 w500,
        Gui, ICScriptHub:Font, w400

        this.AddCurrentRunGroup()
        this.AddOncePerRunGroup()
    }

    ; Adds the current run group box to the stats tab under the reset button
    AddCurrentRunGroup()
    {
        global

        GuiControlGet, pos, ICScriptHub:Pos, Reset_Briv_Farm_Stats_Button

        GUIFunctions.UseThemeTextColor()

        posY := posY + 25
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, GroupBox, x%posX% y%posY% w450 h185 vCurrentRunGroupID, Current `Run:
        Gui, ICScriptHub:Font, w400

        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, Text, vLoopAlignID xp+15 yp+20 , `Loop:
        GuiControlGet, pos, ICScriptHub:Pos, LoopAlignID
        g_LeftAlign := posX
        Gui, ICScriptHub:Add, Text, vLoopID x+2 w400, Not Started
        Gui, ICScriptHub:Font, w400
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+7, Current Area Time (s):
        Gui, ICScriptHub:Add, Text, vdtCurrentLevelTimeID x+2 w200, ; % dtCurrentLevelTime
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Current `Run Time (min):
        Gui, ICScriptHub:Add, Text, vdtCurrentRunTimeID x+2 w50, ; % dtCurrentRunTime

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+10, SB Stack `Count:
        Gui, ICScriptHub:Add, Text, vg_StackCountSBID x+2 w200, ; % g_StackCountSB
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Haste Stack `Count:
        Gui, ICScriptHub:Add, Text, vg_StackCountHID x+2 w200, ; % g_StackCountH

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% yp+25, Boss Levels Hit `This `Run:
        Gui, ICScriptHub:Add, Text, vBossesHitThisRunID x+2 w200,

        GUIFunctions.UseThemeTextColor("SpecialTextColor1", 700)
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+7, Calculated Target Stacks:
        Gui, ICScriptHub:Add, Text, vCalculatedTargetStacksID x+2 w200,

        GUIFunctions.UseThemeTextColor("SpecialTextColor2", 700)
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+5, Ellywick draws:
        Gui, ICScriptHub:Add, Text, x+2 w200 vEllywick_Draws

        GUIFunctions.UseThemeTextColor()
    }

    ; Adds the Once per run group box to the stats tab page under the current run group.
    AddOncePerRunGroup()
    {
        global
        GuiControlGet, pos, ICScriptHub:Pos, CurrentRunGroupID

        GUIFunctions.UseThemeTextColor()

        g_DownAlign := posY + posH -5
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, GroupBox, x%posX% y%g_DownAlign% w450 h280 vOnceRunGroupID, Updated Once Per Full Run:
        Gui, ICScriptHub:Font, w400
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% yp+20, Previous Run Time (min):
        Gui, ICScriptHub:Add, Text, vPrevRunTimeID x+2 w50,
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Fastest Run Time (min):
        Gui, ICScriptHub:Add, Text, vFastRunTimeID x+2 w50,
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Slowest Run Time (min):
        Gui, ICScriptHub:Add, Text, vSlowRunTimeID x+2 w50,

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+10, Total Run `Count:
        Gui, ICScriptHub:Add, Text, vTotalRunCountID x+2 w50,
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Total Run Time (hr):
        Gui, ICScriptHub:Add, Text, vdtTotalTimeID x+2 w50,
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Avg. Run Time (min):
        Gui, ICScriptHub:Add, Text, vAvgRunTimeID x+2 w50,

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+10, Silvers Gained:
        Gui, ICScriptHub:Add, Text, vSilversGainedID x+2 w200, 0
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Golds Gained:
        Gui, ICScriptHub:Add, Text, vGoldsGainedID x+2 w200, 0

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Boss Levels Hit Since Start:
        Gui, ICScriptHub:Add, Text, vTotalBossesHitID x+2 w200,

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, RollBacks Hit Since Start:
        Gui, ICScriptHub:Add, Text, vTotalRollBacksID x+2 w200,

        GUIFunctions.UseThemeTextColor("SpecialTextColor1", 700)
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+10, Bosses per hour:
        Gui, ICScriptHub:Add, Text, vbossesPhrID x+2 w60, ; % bossesPhr

        GUIFunctions.UseThemeTextColor("SpecialTextColor2", 700)
        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+10, Total Gems:
        Gui, ICScriptHub:Add, Text, vGemsTotalID x+2 w200, ; % GemsTotal

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+2, Gems per hour:
        Gui, ICScriptHub:Add, Text, vGemsPhrID x+2 w200, ; % GemsPhr

        Gui, ICScriptHub:Add, Text, x%g_LeftAlign% y+7, Ellywick bonus gems:
        Gui, ICScriptHub:Add, Text, x+2 w200 vEllywick_BonusGems

        GUIFunctions.UseThemeTextColor("WarningTextColor", 700)
        GuiControlGet, pos, ICScriptHub:Pos, bossesPhrID
        posX += 70
        Gui, ICScriptHub:Add, Text, vNordomWarningID x%posX% y%posY% w265,
        GuiControlGet, pos, ICScriptHub:Pos, OnceRunGroupID
        g_DownAlign := g_DownAlign + posH -5

        GUIFunctions.UseThemeTextColor()
    }

    CreateGUI() {
        this.CreateTab("Gem Farm")

        this.AddBrivFarmSection()
        this.AddEllywickRNGWaitingRoomSection()

        this.UpdateGUI()

        this.CreateTab("Stats")
        this.addStats()
    }

    UpdateBrivSettings() {
        GuiControl, ICScriptHub:, Fkeys, % g_BrivUserSettings[ "Fkeys" ]
        GuiControl, ICScriptHub:, DisableDashWait, % g_BrivUserSettings[ "DisableDashWait" ]
        GuiControl, ICScriptHub:, TargetStacks, % g_BrivUserSettings[ "TargetStacks" ]
        GuiControl, ICScriptHub:, AutoCalculateBrivStacks, % g_BrivUserSettings[ "AutoCalculateBrivStacks" ]
    }

    UpdateEllywickSettings() {
        GuiControl, ICScriptHub:, EllywickGFEnabled, % g_BrivUserSettings["EllywickGFEnabled"]
        GuiControl, ICScriptHub:, EllywickGFGemKeepRedrawing, % g_BrivUserSettings["EllywickGFGemKeepRedrawing"]
        GuiControl, ICScriptHub:, EllywickExpectedResults, % g_BrivUserSettings["EllywickExpectedResults"]
    }

    BuildTooltips() {
        this.UpdateBrivSettings()
        this.UpdateEllywickSettings()
        this.EnableTooltips()
    }

    BuildTooltips()
    {
        GUIFunctions.AddToolTip("BrivGemFarmPlayButton", "Start Gem Farm")
        GUIFunctions.AddToolTip("BrivGemFarmStopButton", "Stop Gem Farm")
    }
}

ControlChanged()
{
    Gui, ICScriptHub:Submit, NoHide

    g_BrivUserSettings[ A_GuiControl ] := %A_GuiControl%

    ReloadBrivGemFarmSettings()
}

Briv_Start_Clicked() {
;    IC_BrivGemFarm_Component.Briv_Run_Clicked()
}

Briv_Stop_Clicked() {
;    IC_BrivGemFarm_Component.Briv_Run_Stop_Clicked()
}

Reset_Briv_Farm_Stats()
{
    g_BrivGemFarmStats.ResetBrivFarmStats()
}
