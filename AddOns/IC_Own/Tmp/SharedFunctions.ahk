#include %A_LineFile%\..\..\IC_Core\IC_SharedFunctions_Class.ahk

class IC_BrivSharedFunctions_Class extends IC_SharedFunctions_Class
{
/*
    steelbones := ""
    sprint := ""
    PatronID := 0
    ; Force adventure reset rather than relying on modron to reset.
    RestartAdventure( reason := "" )
    {
            g_SharedData.LoopString := "ServerCall: Restarting adventure"
            this.CloseIC( reason )
            if (this.sprint != "" AND this.steelbones != "" AND (this.sprint + this.steelbones) < 190000)
            {
                response := g_serverCall.CallPreventStackFail(this.sprint + this.steelbones)
            }
            else if (this.sprint != "" AND this.steelbones != "")
            {
                response := g_serverCall.CallPreventStackFail(this.sprint + this.steelbones)
                g_SharedData.LoopString := "ServerCall: Restarting with >190k stacks, some stacks lost."
            }
            else
            {
                g_SharedData.LoopString := "ServerCall: Restarting adventure (no manual stack conv.)"
            }
            response := g_ServerCall.CallEndAdventure()
            response := g_ServerCall.CallLoadAdventure( this.CurrentAdventure )
            g_SharedData.TriggerStart := true
    }

    ; Store important user data [UserID, Hash, InstanceID, Briv Stacks, Gems, Chests]
    SetUserCredentials()
    {
        this.UserID := this.Memory.ReadUserID()
        this.UserHash := this.Memory.ReadUserHash()
        this.InstanceID := this.Memory.ReadInstanceID()
        ; needed to know if there are enough chests to open using server calls
        this.TotalGems := this.Memory.ReadGems()
        silverChests := this.Memory.ReadChestCountByID(1)
        goldChests := this.Memory.ReadChestCountByID(2)
        this.TotalSilverChests := (silverChests != "") ? silverChests : this.TotalSilverChests
        this.TotalGoldChests := (goldChests != "") ? goldChests : this.TotalGoldChests
        this.sprint := this.Memory.ReadHasteStacks()
        this.steelbones := this.Memory.ReadSBStacks()
    }

    ; sets the user information used in server calls such as user_id, hash, active modron, etc.
    ResetServerCall()
    {
        this.SetUserCredentials()
        g_ServerCall := new IC_BrivServerCall_Class( this.UserID, this.UserHash, this.InstanceID )
        version := this.Memory.ReadBaseGameVersion()
        if (version != "")
            g_ServerCall.clientVersion := version
        tempWebRoot := this.Memory.ReadWebRoot()
        httpString := StrSplit(tempWebRoot,":")[1]
        isWebRootValid := httpString == "http" or httpString == "https"
        g_ServerCall.webroot := isWebRootValid ? tempWebRoot : g_ServerCall.webroot
        g_ServerCall.networkID := this.Memory.ReadPlatform() ? this.Memory.ReadPlatform() : g_ServerCall.networkID
        g_ServerCall.activeModronID := this.Memory.ReadActiveGameInstance() ? this.Memory.ReadActiveGameInstance() : 1 ; 1, 2, 3 for modron cores 1, 2, 3
        g_ServerCall.activePatronID := this.PatronID ;this.Memory.ReadPatronID() == "" ? g_ServerCall.activePatronID : this.Memory.ReadPatronID() ; 0 = no patron
        g_ServerCall.UpdateDummyData()
    }


    ;  WaitForModronReset - A function that monitors a modron resetting process.
    ;
    ;  Returns:
    ;  bool - true if completed successfully; returns false if reset does not occur within 75s
    WaitForModronReset( timeout := 75000)
    {
        StartTime := A_TickCount
        ElapsedTime := 0
        g_SharedData.LoopString := "Modron Resetting..."
        this.SetUserCredentials()
        if (this.sprint != "" AND this.steelbones != "" AND (this.sprint + this.steelbones) < 190000)
            response := g_serverCall.CallPreventStackFail( this.sprint + this.steelbones, true)
        while (this.Memory.ReadResetting() AND ElapsedTime < timeout)
        {
            ElapsedTime := A_TickCount - StartTime
            Sleep, 20
        }
        g_SharedData.LoopString := "Loading z1..."
        Sleep, 50
        while ( !this.Memory.ReadUserIsInited() AND g_SF.Memory.ReadCurrentZone() < 1 AND ElapsedTime < timeout )
        {
            ElapsedTime := A_TickCount - StartTime
            Sleep, 20
        }
        if (ElapsedTime >= timeout)
        {
            return false
        }
        return true
    }

    ; Refocuses the window that was recorded as being active before the game window opened.
    ActivateLastWindow()
    {
        if (!g_BrivUserSettings["RestoreLastWindowOnGameOpen"])
            return
        Sleep, 100 ; extra wait for window to load
        hwnd := this.Hwnd
        WinActivate, ahk_id %hwnd% ; Idle Champions likes to be activated before it can be deactivated
        savedActive := this.SavedActiveWindow
        WinActivate, %savedActive%
    }

    ; Returns true when conditions have been met for starting a wait for dash.
    ShouldDashWait()
    {
        if (g_BrivUserSettings[ "DisableDashWait" ])
            return False
        isInDashWaitBuffer := this.Memory.ReadCurrentZone() >= ( this.ModronResetZone - g_BrivUserSettings[ "DashWaitBuffer" ] )
        if (isInDashWaitBuffer)
            return False
        hasHasteStacks := this.Memory.ReadHasteStacks() > 50
        if (!hasHasteStacks)
            Return False
        isShandieInFormation := this.IsChampInFormation( 47, this.Memory.GetCurrentFormation() )
        if (!isShandieInFormation)
            return False

        return True
    }

    ; Wait for Thellora ?
    ShouldRushWait()
    {
        if !(this.Memory.ReadCurrentZone() >= 0 AND this.Memory.ReadCurrentZone() <= 3)
            return False
        rushStacks := ActiveEffectKeySharedFunctions.Thellora.ThelloraPlateausOfUnicornRunHandler.ReadRushStacks()
        if !(rushStacks > 0 AND rushStacks < 10000)
            return False
        return True
    }

    DoRushWait()
    {
        this.ToggleAutoProgress( 0, false, true )
        this.Memory.ActiveEffectKeyHandler.Refresh()
        StartTime := A_TickCount
        ElapsedTime := 0
        timeout := 8000 ; 7s seconds
        estimate := (timeout / timeScale) ; no buffer: 60s / timescale to show in LoopString

        ActiveEffectKeySharedFunctions.Thellora.ThelloraPlateausOfUnicornRunHandler.ReadRushStacks()
        ; Loop escape conditions:
        ;   does full timeout duration
        ;   past highest accepted dashwait triggering area
        ;   dash is active, dash.GetScaleActive() toggles to true when dash is active and returns "" if fails to read.
        while ( ElapsedTime < timeout AND this.ShouldRushWait() )
        {
            this.ToggleAutoProgress(0)
            this.SetFormation()
            ElapsedTime := A_TickCount - StartTime
            g_SharedData.LoopString := "Rush Wait: " . ElapsedTime . " / " . estimate
            percentageReducedSleep := Max(Floor((1-(ElapsedTime/estimate))*estimate/10), 15)
            Sleep, %percentageReducedSleep%
        }
        g_PreviousZoneStartTime := A_TickCount
        return
    }
*/
}

global g_SF := new IC_BrivSharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory
