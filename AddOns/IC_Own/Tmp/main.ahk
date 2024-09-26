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

#include %A_LineFile%\..\..\..\SharedFunctions\json.ahk
#include %A_LineFile%\..\Functions.ahk
;server call functions and variables Included after GUI so chest tabs maybe non optimal way of doing it
#include %A_LineFile%\..\..\IC_Core\IC_SaveHelper_Class.ahk
#include %A_LineFile%\..\IC_BrivGemFarm_Settings.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\SH_GUIFunctions.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\SH_UpdateClass.ahk

;Load user settings
global g_UserSettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\..\..\Settings.json" )
global g_KeyMap:= {}
global g_SCKeyMap:= {}
KeyHelper.BuildVirtualKeysMap(g_KeyMap, g_SCKeyMap)
global g_InputsSent := 0
global g_SaveHelper := new IC_SaveHelper_Class
global g_BrivUserSettingsFromAddons := {}


; Show GUI
BrivGemFarmGUI := new BrivGemFarmGUI()
BrivGemFarmGUI.CreateGUI()
