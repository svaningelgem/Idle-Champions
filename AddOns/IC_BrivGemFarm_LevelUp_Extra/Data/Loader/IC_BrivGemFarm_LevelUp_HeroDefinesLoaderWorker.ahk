#include %A_LineFile%\..\IC_BrivGemFarm_LevelUp_ServerCalls_Class.ahk
#include %A_LineFile%\..\..\..\..\..\SharedFunctions\SH_VersionHelper.ahk

global g_ServerCall := new IC_BrivGemFarm_LevelUp_ServerCalls_Class

Class IC_BrivGemFarm_LevelUp_HeroDefinesLoaderWorker
{
    ; Parser version
    static Version := "1.3.3"
    ; File locations
    static HeroDefsPath := A_LineFile . "\..\..\HeroDefines.json"
    static LastGUIDPath := A_LineFile . "\..\LastGUID_BrivGemFarm_LevelUp.json"
    static LoaderTempPath := A_LineFile . "\..\LastTableChecksums.txt"
    ; Filters
    static TableFilter := "table_checksums"
    static HeroFilter := "hero_defines"
    static UpgradeFilter := "upgrade_defines"
    static EffectFilter := "effect_defines"
    static EffectKeyFilter := "effect_key_defines"
    static AttackFilter := "attack_defines"
    static TextFilter := "text_defines"
    ; Loader states
    static STOPPED := 0
    static GET_PLAYSERVER := 1
    static CHECK_TABLECHECKSUMS := 2
    static FILE_PARSING := 3
    static TEXT_DEFS := 4
    static HERO_DEFS := 5
    static ATTACK_DEFS := 6
    static UPGRADE_DEFS := 7
    static EFFECT_DEFS := 8
    static EFFECT_KEY_DEFS := 9
    static FILE_SAVING := 10
    static HERO_DATA_FINISHED := 100
    static HERO_DATA_FINISHED_NOUPDATE := 101
    static SERVER_TIMEOUT := 200
    static DEFS_LOAD_FAIL := 201

    HeroDefines := ""
    LastTableChecksums := ""
    CurrentState := 0
    IsNewLoaderVersion := false

    Start(languageID := 1)
    {
        ; Get playerserver for definitions
        this.UpdateLoaderState(this.GET_PLAYSERVER)
        if (g_ServerCall.GetWebRoot() == "")
        {
            this.UpdateLoaderState(this.SERVER_TIMEOUT)
            return this.DoCallBack(2)
        }
        ; Check if new table_checksums (always true when loading a new language)
        this.UpdateLoaderState(this.CHECK_TABLECHECKSUMS)
        this.LastTableChecksums := this.GetLastTableChecksums()
        isNewDefs := this.CheckForNewdefs(languageID, this.LastTableChecksums)
        isNewVersion := this.CheckIfNewParserVersion()
        fileExists := FileExist(this.HeroDefsPath)
        if (isNewVersion || isNewDefs || !fileExists)
        {
            ; Get filtered defs
            defs := g_ServerCall.CallGetHeroDefs(languageID, this.Filter)
            ; Process new definitions
            this.Preprocess(defs)
            if (this.HeroDefines == "")
            {
                this.UpdateLoaderState(this.DEFS_LOAD_FAIL)
                return this.DoCallBack(2)
            }
            ; Save new definitions
            this.UpdateLoaderState(this.FILE_SAVING)
            this.WriteObjectToJSON(this.HeroDefsPath, this.HeroDefines)
            ; Save new checksums
            this.FileWrite(this.LoaderTempPath, this.LastTableChecksums)
            ; Save new version
            if (this.IsNewLoaderVersion)
                this.UpdateParserVersion()
            this.CurrentState := this.HERO_DATA_FINISHED
        }
        else
            this.CurrentState := this.HERO_DATA_FINISHED_NOUPDATE
        this.DoCallBack(10)
    }

    ; Returns true if the parser has been updated since last execution.
    CheckIfNewParserVersion()
    {
        loaderSettings := this.LoadObjectFromJSON(this.LastGUIDPath)
        oldVersion := loaderSettings.Version
        isNew := oldVersion == "" || SH_VersionHelper.IsVersionNewer(this.Version, oldVersion)
        this.IsNewLoaderVersion := isNew
        return isNew
    }

    ; Update parser version.
    UpdateParserVersion()
    {
        loaderSettings := this.LoadObjectFromJSON(this.LastGUIDPath)
        if (!IsObject(loaderSettings))
            loaderSettings := {}
        loaderSettings.Version := this.Version
        this.WriteObjectToJSON(this.LastGUIDPath, loaderSettings)
    }

    ; Returns table_checksums for args
    GetLastTableChecksums(fileName := "")
    {
        if (fileName == "")
            fileName := this.LoaderTempPath
        fileExists := FileExist(fileName)
        if (fileExists)
        {
            FileRead, contents, %fileName%
            return contents
        }
        return ""
    }

    ; Parse contents looking for <table_checksums>.
    FindTableChecksums(contents)
    {
        RegExMatch(contents, "{([^}]+)}", tableChecksums, InStr(contents, """table_checksums"":"))
        return this.GetCommaSeparatedKeys(tableChecksums1)
    }

    ; Parse contents looking for <passed_table_checksums>.
    FindPassedTableChecksums(contents)
    {
        RegExMatch(contents, "\[([^]]+)\]", passedChecksums, InStr(contents, """passed_table_checksums"":"))
        return this.GetCommaSeparatedKeys(passedChecksums1)
    }

    ; Format checksums so they are separated by commas without colons.
    ; Input: <"key":int> -> Output: <key:int.>.
    GetCommaSeparatedKeys(contents)
    {
        contents := StrReplace(contents, "`r`n")
        contents := StrReplace(contents, "`t")
        return StrReplace(contents, """")
    }

    ; Check if the latest table_checksums from the server match previous table_checksums.
    ; Params: - languageID:int - Language.
    ;           1:English, 2:Deutsch, 3:Pусский, 4:Français, 5:Português, 6:Español, 7:中文".
    ;         - table_checksums:str - List of key/value pairs separated by commas.
    CheckForNewdefs(languageID := 1, table_checksums := "")
    {
        response := g_ServerCall.CallCheckTableChecksums(languageID, table_checksums)
        last := this.LastTableChecksums
        new := this.FindTableChecksums(response)
        if (new != last || last == "")
        {
            if (last != "")
            {
                ; Only update if new keys are part of filter.
                passed := this.FindPassedTableChecksums(response)
                if (this.CompareTableCheckSums(new, passed, this.Filter))
                    return false
            }
            this.LastTableChecksums := new
            return true
        }
        return false
    }

    ; Check if new checksums have keys present in filter.
    ; Params: - new:str - List of key/value pairs separated by commas.
    ;         - passed:str - List of key/value pairs separated by commas.
    ;         - filter:str - List of keys separated by commas.
    ; All keys in <passed> should also be found in <new>.
    CompareTableCheckSums(new, passed, filter := "")
    {
        regexKey := "O)(\w+):\d+"
        regexBaseKey := "(\w+)_\d+"
        nextPos := 1
        ; Get keys (e.g. attack_defines)
        while (nextPos := RegExMatch(new, regexKey, matchO, nextPos) + matchO.len())
        {
            key := matchO.value(1)
            ; Get base key (e.g. upgrade_defines_0 -> upgrade_defines)
            RegExMatch(key, regexBaseKey, baseKey)
            basekey := basekey1 == "" ? key : basekey1
            if baseKey in %filter%
            {
                ; New checksum for filtered key
                if key not in %passed%
                    return false
            }
        }
        return true
    }

    Filter
    {
        get
        {
            filter := this.HeroFilter . ","
            filter .= this.UpgradeFilter . ","
            filter .= this.EffectFilter . ","
            filter .= this.EffectKeyFilter . ","
            filter .= this.AttackFilter . ","
            filter .= this.TextFilter
            return filter
        }
    }

    ; Convert data from a JSON file to an ahk object.
    LoadObjectFromJSON(fileName)
    {
        FileRead, oData, %fileName%
        data := ""
        try
        {
            data := JSON.parse( oData )
        }
        catch err
        {
            err.Message := err.Message . "`nFile:`t" . fileName
            throw err
        }
        return data
    }

    ; Update args from the file written by ICScriptHub.
    ; g_LanguageID could be incorrectly passed by ICScriptHub.
    ; g_GUID is updated if ICScriptHub has been closed before the final callback.
    UpdateArgsFromFile()
    {
        args := this.LoadObjectFromJSON(this.LastGUIDPath)
        g_LanguageID := args.LanguageID
        g_GUID := args.GUID
    }

    ; Write contents to a text file.
    FileWrite(path, contents)
    {
        FileDelete, %path%
        FileAppend, % contents, %path%, UTF-8
    }

    ; Write json (object) to a file (fileName).
    WriteObjectToJSON(fileName, ByRef object)
    {
        objectJSON := JSON.stringify(object)
        FileDelete, %fileName%
        FileAppend, %objectJSON%, %fileName%, UTF-8
    }

    ; Process definitions so only relevant data for BGFLU is kept.
    ; Params: - data:str - Data to parse.
    Preprocess(data)
    {
        ; Convert to AHK object
        this.UpdateLoaderState(this.FILE_PARSING)
        data := JSON.parse(data)
        ; Remove unused keys
        this.DeleteServerStats(data)
        this.HeroDefines := {current_time:data.current_time}
        this.UpdateLoaderState(this.TEXT_DEFS)
        this.ProcessTextDefs(data)
        this.UpdateLoaderState(this.HERO_DEFS)
        this.ProcessHeroDefs(data)
        this.UpdateLoaderState(this.ATTACK_DEFS)
        this.ProcessAttackDefs(data)
        this.UpdateLoaderState(this.UPGRADE_DEFS)
        this.ProcessUpgradeDefs(data)
        this.UpdateLoaderState(this.EFFECT_DEFS)
        this.ProcessEffectDefs(data)
        this.UpdateLoaderState(this.EFFECT_KEY_DEFS)
        this.ProcessEffectKeyDefs(data)
    }

    ; Replace UTF char codes by the corresponding character.
    ; Params: - data:str - Data to parse.
    ReplaceUTFChars(ByRef data)
    {
        regexChar := "\\u([0-9a-f]+)"
        while (RegExMatch(data, "O)" . regexChar, matchO))
        {
            char := Chr("0x" . matchO[1])
            data := StrReplace(data, matchO[0], char,, 1)
        }
    }

    ; Delete entries related to server stats.
    ; Params: - data:obj - AHK object to parse.
    DeleteServerStats(ByRef data)
    {
        data.Delete("apc_stats")
        data.Delete("db_stats")
        data.Delete("memory_usage")
        data.Delete("memory_usage")
        data.Delete("processing_time")
        data.Delete("success")
        return data
    }

    ProcessTextDefs(ByRef data)
    {
        text_defines := {}
        for k, v in data.text_defines
        {
            key := v.key
            v.Delete("id")
            v.Delete("key")
            text_defines[key] := v
        }
        this.HeroDefines.text_defines := text_defines
    }

    ProcessHeroDefs(ByRef data)
    {
        hero_defines := {}
        for k, v in data.hero_defines
        {
            if (RegExMatch(v.name, "Y\d+E\d+") OR ErrorLevel != 0) ; skip placeholder
                continue
            obj := {name:v.name, seat_id:v.seat_id, ultimate_attack_id:v.ultimate_attack_id}
            for k1, v1 in ["is_available", "last_rework_date"]
                if (v.HasKey(v1) AND v[v1] != "")
                    obj[v1] := v[v1]
            hero_defines[v.id] := obj
        }
        this.HeroDefines.hero_defines := hero_defines
    }

    ProcessAttackDefs(ByRef data)
    {
        attack_defines := {}
        for k, v in data.attack_defines
        {
            obj := {}
            for k1, v1 in ["description", "long_description", "name"]
                if (v.HasKey(v1) AND v[v1] != "")
                    obj[v1] := v[v1]
            attack_defines[v.id] := obj
        }
        this.HeroDefines.attack_defines := attack_defines
    }

    ProcessUpgradeDefs(ByRef data)
    {
        defs := this.HeroDefines
        defs.upgrade_defines := {}
        for k, v in data.upgrade_defines
        {
            hero_id := v.hero_id
            required_level := v.required_level
            obj := {hero_id:hero_id, required_level:required_level}
            heroDef := defs.hero_defines[hero_id]
            if (v.name != "")
                obj.name := v.name
            if (v.upgrade_type != "")
                obj.upgrade_type := v.upgrade_type
            if ((effect := v.effect) != "")
            {
                if (RegExMatch(effect, "effect_string")) ; Convert string to Object
                {
                    this.ReplaceUTFChars(effect)
                    fixedEffect := {}
                    nextPos := 1
                    regex := "O)""\b([^""]+)""\B:(?:\s?)+""?([^""]+)(?:""|,|})\B"
                    while (nextPos := RegExMatch(effect, regex, matchO, nextPos) + matchO.len())
                        fixedEffect[matchO.value(1)] := matchO.value(2)
                    v.effect := fixedEffect
                }
                obj.effect := v.effect
            }
            if (v.specialization_name)
                obj.specialization_name := v.specialization_name
            if (v.specialization_description)
                obj.specialization_description := v.specialization_description
            if (v.tip_text)
                obj.tip_text := v.tip_text
            defs.upgrade_defines[v.id] := obj
            if (required_level == 9999)
                continue
            if (heroDef.tempUpgrades.HasKey(required_level))
            {
                if (IsObject(heroDef.tempUpgrades[required_level]))
                    heroDef.tempUpgrades[required_level].Push(v.id)
                else
                    heroDef.tempUpgrades[required_level] := [heroDef.tempUpgrades[required_level], v.id]
            }
            else
                heroDef.tempUpgrades[required_level] := v.id
        }
        ; Sort upgrades by required_level
        for k, v in defs.hero_defines
        {
            upgrades := []
            for k1, v1 in v.tempUpgrades
            {
                if (IsObject(v1))
                    upgrades.Push(v1*)
                else
                    upgrades.Push(v1)
            }
            v.upgrades := upgrades
            v.Delete("tempUpgrades")
        }
    }

    ProcessEffectDefs(ByRef data)
    {
        effect_defines := {}
        for k, v in data.effect_defines
        {
            id := v.id
            v.Delete("id")
            v.Delete("graphic_id")
            for k1, v1 in ["description", "effect_keys", "flavour_text", "properties", "requirements"]
                if (v.HasKey(v1) AND (v[v1] == "" OR v[v1].Count() == 0))
                    v.Delete(v1)
            effect_defines[id] := v
        }
        this.HeroDefines.effect_defines := effect_defines
    }

    ProcessEffectKeyDefs(ByRef data)
    {
        effect_key_defines := {}
        for k, v in data.effect_key_defines
        {
            key := v.key
            v.Delete("id")
            v.Delete("key")
            for k1, v1 in ["descriptions", "owner", "param_names", "properties"]
                if (v.HasKey(v1) AND (v[v1] == "" OR v[v1].Count() == 0))
                    v.Delete(v1)
            effect_key_defines[key] := v
        }
        this.HeroDefines.effect_key_defines := effect_key_defines
    }

    ; Connect to the COM object for this addon before exiting.
    ; Params: retry:int - Maximum number of attempts (once every 1000ms).
    DoCallBack(retry := 0)
    {
        try
        {
            addonClass := ComObjActive(g_GUID)
            addonClass.UpdateState(this.CurrentState)
        }
        catch
        {
            if (retry)
            {
                this.UpdateArgsFromFile()
                params := [--retry]
                func := ObjBindMethod(this, "RetryCallBack", params*)
                SetTimer, %func%, -1000
                return
            }
        }
        ExitApp
    }

    RetryCallBack(params*)
    {
        this.DoCallBack(params*)
    }

    ; Connect to the COM object for this addon and update current loading status.
    UpdateLoaderState(state)
    {
        this.CurrentState := state
        try
        {
            addonClass := ComObjActive(g_GUID)
            addonClass.UpdateState(state)
        }
    }
}