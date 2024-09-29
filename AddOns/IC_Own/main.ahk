#SingleInstance force
;put together with the help from many different people. thanks for all the help.

;=======================
;Script Optimization
;=======================
#HotkeyInterval 1000  ; The default value is 2000 (milliseconds).
#MaxHotkeysPerInterval 70 ; The default value is 70
#NoEnv ; Avoids checking empty variables to see if they are environment variables (recommended for all new scripts). Default behavior for AutoHotkey v2.
SetWorkingDir %A_ScriptDir%
SetWinDelay, 33 ; Sets the delay that will occur after each windowing command, such as WinActivate. (Default is 100)
SetControlDelay, 0 ; Sets the delay that will occur after each control-modifying command. -1 for no delay, 0 for smallest possible delay. The default delay is 20.
;SetKeyDelay, 0 ; Sets the delay that will occur after each keystroke sent by Send or ControlSend. [SetKeyDelay , Delay, PressDuration, Play]
SetBatchLines, -1 ; How fast a script will run (affects CPU utilization).(Default setting is 10ms - prevent the script from using any more than 50% of an idle CPU's time.
                  ; This allows scripts to run quickly while still maintaining a high level of cooperation with CPU sensitive tasks such as games and video capture/playback.
ListLines Off
Process, Priority,, High
CoordMode, Mouse, Client

#include %A_LineFile%\..\_shared_functions.class.ahk
#include %A_LineFile%\..\_servercall.class.ahk
#include %A_LineFile%\..\_gemfarm.class.ahk
#include %A_LineFile%\..\_settings.ahk
#include %A_LineFile%\..\_globals.ahk
#include %A_LineFile%\..\GUI.ahk
#include %A_LineFile%\..\_stats.class.ahk


GemFarmGUI := new CombinedGemFarmGUI()
GemFarmGUI.CreateGUI()


#include %A_LineFile%\..\_runner.ahk

Briv_Start_Clicked() {
    GuiControl, ICScriptHub:Disable, BrivGemFarmPlayButton
    GuiControl, ICScriptHub:Enable, BrivGemFarmStopButton

    Runner.Briv_Run_Clicked()
}

Briv_Stop_Clicked() {
    GuiControl, ICScriptHub:Enable, BrivGemFarmPlayButton
    GuiControl, ICScriptHub:Disable, BrivGemFarmStopButton

    Runner.Briv_Run_Stop_Clicked()
}
