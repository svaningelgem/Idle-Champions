#include %A_LineFile%\..\..\..\ServerCalls\IC_ServerCalls_Class.ahk

class IC_BrivServerCall_Class extends IC_ServerCalls_Class
{
/*
    ; forces an attempt for the server to remember stacks
    CallPreventStackFail(stacks, launchScript := False)
    {
        response := ""
        stacks := g_SaveHelper.GetEstimatedStackValue(stacks)
        userData := g_SaveHelper.GetCompressedDataFromBrivStacks(stacks)
        checksum := g_SaveHelper.GetSaveCheckSumFromBrivStacks(stacks)
        save :=  g_SaveHelper.GetSave(userData, checksum, this.userID, this.userHash, this.networkID, this.clientVersion, this.instanceID)
        if (launchScript) ; do server call from new script to prevent hanging script due to network issues.
        {
            webRoot := this.webRoot
            scriptLocation := A_LineFile . "\..\IC_BrivGemFarm_SaveStacks.ahk"
            Run, %A_AhkPath% "%scriptLocation%" "%webRoot%" "%save%"
        }
        else
        {
            try
            {
                response := this.ServerCallSave(save)
            }
            catch, ErrMsg
            {
                g_SharedData.LoopString := "Failed to save Briv stacks"
            }
        }
        return response
    }
*/
}

global g_ServerCall
