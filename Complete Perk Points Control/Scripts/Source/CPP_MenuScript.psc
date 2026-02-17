Scriptname CPP_MenuScript extends SKI_ConfigBase  

GlobalVariable Property CPP_ModEnabled auto
string[] Property CPP_SkillNames auto
GlobalVariable[] Property CPP_SkillsDisabled auto
GlobalVariable[] Property CPP_PerkPointsEarned auto
GlobalVariable Property CPP_StartingLevel auto
GlobalVariable Property CPP_LevelInterval auto
GlobalVariable Property CPP_MaxSkillLevel auto
GlobalVariable Property CPP_ShowNotifications auto
GlobalVariable Property CPP_GlobalSkillMode_Enabled auto
GlobalVariable Property CPP_GlobalSkillMode_PerkPointsEarned auto
GlobalVariable Property CPP_GlobalSkillMode_LevelProgress auto
GlobalVariable[] Property CPP_LastSkillLevel auto
GlobalVariable Property CPP_PlayerLevelMode_Enabled auto
GlobalVariable Property CPP_PlayerLevelMode_PerkPointsEarned auto
GlobalVariable Property CPP_PerkPointsMultiplier auto
GlobalVariable Property CPP_LegendarySkillsEnabled auto
GlobalVariable[] Property CPP_SkillLegendaryCount auto
GlobalVariable Property CPP_CustomSkills_MCMEnabled auto
GlobalVariable Property CPP_CustomSkills_Enabled auto
GlobalVariable Property CPP_CustomSkills_GlobalProgressionMode auto
GlobalVariable Property CPP_CustomSkills_StartingLevel auto
GlobalVariable Property CPP_CustomSkills_LevelInterval auto
GlobalVariable Property CPP_CustomSkills_MaxLevel auto
GlobalVariable Property CPP_CustomSkills_PerkPointsMultiplier auto
GlobalVariable Property CPP_CustomSkills_HasSelectedProgression auto
GlobalVariable Property CPP_Spell_SoulToPoint_SoulsNeeded auto
GlobalVariable Property CPP_Spell_SoulToPoint_Points auto
GlobalVariable Property CPP_DragonDeaths_Enabled auto
GlobalVariable Property CPP_DragonDeaths_SoulsNeeded auto
GlobalVariable Property CPP_DragonDeaths_Points auto
GlobalVariable Property CPP_Menu_HasSelectedProgression auto
GlobalVariable Property CPP_Menu_HasDetectedLegendary auto
; GlobalVariable Property CPP_LegendaryPowerBonusEnabled auto
; GlobalVariable Property CPP_LegendaryPowerBonusValue auto
; Message Property CPP_MessageBox_Confirm auto

; int totalPointsToAdd = 0
int totalMissing = 0
bool debugCheaterToggle = false
float debugCheaterPerkPoints = 1.0
string[] menuOptions
int[] savedPerkPointsEarnedNormal
int savedPerkPointsEarnedGlobal
int savedPerkPointsEarnedPlayer

; MCM Option IDs
int OID_ModEnabled
int OID_GlobalSkillProgressionMode
int OID_PlayerLevelProgressionMode
int OID_ProgressionMode
int OID_LegendarySkillsEnabled
int OID_StartingLevel
int OID_LevelInterval  
int OID_MaxSkillLevel
int OID_ShowNotifications
int OID_CustomSkills_Enabled
int OID_CustomSkills_ProgressionMode
int OID_CustomSkills_StartingLevel
int OID_CustomSkills_LevelInterval
int OID_CustomSkills_MaxLevel
int OID_CustomSkills_PerkPointsMultiplier
int OID_AddMissingPoints
int OID_UndoAddedMissedPoints
int[] OID_SkillsDisabled
int OID_CheaterToggle
int OID_CheaterPerkPoints
int OID_CheaterAdd
int OID_CheaterRemove
int OID_PointsMultiplier
int OID_SpellSouls
int OID_SpellPoints
int OID_DragonEnabled
int OID_DragonSouls
int OID_DragonPoints
int OID_DetectLegendary
int OID_PerkPointsLevelsPreview
int OID_PerkPointsPreview  
int OID_PerkPointsExcess
int[] OID_LegendarySkills
int OID_LegendaryPowerBonusEnabled
int OID_LegendaryPowerBonusValue



Event OnConfigInit()
    ModName = "Complete Perk Points Control"
    Pages = new string[4]
    Pages[0] = "General"
    Pages[1] = "Excluded Skills"
    Pages[2] = "Custom Skills"
    ; Pages[2] = "Legendary Bonuses"
    Pages[3] = "Debug"
EndEvent

Event OnPageReset(string page)
    if page == ""
        LoadCustomContent("Complete Perk Points Control/MCM.dds")
    else
        UnloadCustomContent()
    endif

    if page == "General"
        SetCursorFillMode(TOP_TO_BOTTOM)
        ;SetCursorPosition(0)
        
        AddHeaderOption("General Settings")
        OID_ModEnabled = AddToggleOption("Enable Mod", CPP_ModEnabled.GetValue())
        OID_LegendarySkillsEnabled = AddToggleOption("Legendary Skill Rewards", CPP_LegendarySkillsEnabled.GetValue())
        OID_ShowNotifications = AddToggleOption("Notifications", CPP_ShowNotifications.GetValue())
        AddEmptyOption()

        AddHeaderOption("Progression Type")
        OID_ProgressionMode = AddMenuOption("", GetProgressionMode(), CPP_Menu_HasSelectedProgression.GetValueInt())
        AddEmptyOption()
        
        AddHeaderOption("Rewards")
        OID_StartingLevel = AddSliderOption("Starting Level", CPP_StartingLevel.GetValue(), "{0}")
        OID_LevelInterval = AddSliderOption("Level Interval", CPP_LevelInterval.GetValue(), "{0}")
        OID_MaxSkillLevel = AddSliderOption("Max Skill Level", CPP_MaxSkillLevel.GetValue(), "{0}")
        OID_PointsMultiplier = AddSliderOption("Reward Multiplier", CPP_PerkPointsMultiplier.GetValueInt(), "{0}")
        AddEmptyOption()

        AddHeaderOption("Soul Conversion")
        OID_SpellSouls = AddSliderOption("Souls Required", CPP_Spell_SoulToPoint_SoulsNeeded.GetValue(), "{0}")
        OID_SpellPoints = AddSliderOption("Points per Reward", CPP_Spell_SoulToPoint_Points.GetValue(), "{0}")
        AddEmptyOption()

        AddHeaderOption("Dragon Soul Rewards")
        OID_DragonEnabled = AddToggleOption("Enable Soul Rewards", CPP_DragonDeaths_Enabled.GetValue())
        OID_DragonSouls = AddSliderOption("Souls Required", CPP_DragonDeaths_SoulsNeeded.GetValue(), "{0}")
        OID_DragonPoints = AddSliderOption("Points per Reward", CPP_DragonDeaths_Points.GetValue(), "{0}")
        AddEmptyOption()

        SetCursorPosition(1) ; Move to right column
        
        AddHeaderOption("Recalculation")
        OID_AddMissingPoints = AddTextOption("Recalculate Rewards", "APPLY")
        OID_UndoAddedMissedPoints = AddTextOption("Revert Changes", "REVERT")
        AddEmptyOption()
        AddEmptyOption()
        
        AddHeaderOption("Progression Preview")
        OID_PerkPointsLevelsPreview = AddTextOption("Reward Levels:", GetPerkLevelsPreview())
        OID_PerkPointsPreview = AddTextOption("Points per Skill:", GetPerkPointsPreview())
        OID_PerkPointsExcess = AddTextOption("Deferred Points:", ExcessPointsCalculate())

    elseif page == "Excluded Skills"
        SetCursorFillMode(TOP_TO_BOTTOM)
        
        OID_SkillsDisabled = new int[18]

        AddHeaderOption("Skills to Exclude")
        AddEmptyOption()

        int i = 0
        while i < 8
            OID_SkillsDisabled[i] = AddToggleOption(CPP_SkillNames[i], CPP_SkillsDisabled[i].GetValue())
            i += 1
        EndWhile

        SetCursorPosition(1)
        while i < 18
            OID_SkillsDisabled[i] = AddToggleOption(CPP_SkillNames[i], CPP_SkillsDisabled[i].GetValue())
            i += 1
        EndWhile

    elseif page =="Custom Skills"
        bool pluginActive = (CPP_CustomSkills_MCMEnabled.GetValueInt() == 1)
        int flags = OPTION_FLAG_NONE
        
        SetCursorFillMode(TOP_TO_BOTTOM)

        if (pluginActive)
            AddHeaderOption("Custom Skills")
        else
            AddHeaderOption("SKSE plugin not loaded")
            flags = OPTION_FLAG_DISABLED
        endif
        
        OID_CustomSkills_Enabled = AddToggleOption("Enable Rewards", CPP_CustomSkills_Enabled.GetValueInt(), flags)

        AddEmptyOption()
        AddHeaderOption("Progression Type")
        OID_CustomSkills_ProgressionMode = AddMenuOption("", GetCustomSkillsProgressionMode(), CPP_CustomSkills_HasSelectedProgression.GetValueInt())
        AddEmptyOption()

        ;OID_CustomSkills_GlobalProgressionMode = AddToggleOption("Shared Progression Pool", CPP_CustomSkills_GlobalProgressionMode.GetValueInt(), flags)
        OID_CustomSkills_StartingLevel = AddSliderOption("Starting Level", CPP_CustomSkills_StartingLevel.GetValueInt(), "{0}", flags)
        OID_CustomSkills_LevelInterval = AddSliderOption("Level Interval", CPP_CustomSkills_LevelInterval.GetValueInt(), "{0}", flags)
        OID_CustomSkills_MaxLevel = AddSliderOption("Max Skill Level", CPP_CustomSkills_MaxLevel.GetValueInt(), "{0}", flags)
        OID_CustomSkills_PerkPointsMultiplier = AddSliderOption("Reward Multiplier", CPP_CustomSkills_PerkPointsMultiplier.GetValueInt(), "{0}", flags)
        

    ; elseif page == "Legendary Bonuses"
    ;     SetCursorFillMode(TOP_TO_BOTTOM)

    ;     OID_LegendarySkills = new int[18]

    ;     ; AddHeaderOption("Select To Disable")
    ;     OID_LegendaryPowerBonusEnabled = AddToggleOption("Enable Legendary Skill Bonus", CPP_LegendaryPowerBonusEnabled.GetValue())
    ;     OID_LegendaryPowerBonusValue = AddSliderOption("Bonus Per Legendary", CPP_LegendaryPowerBonusValue.GetValue(), "{0}")
    ;     AddEmptyOption()

    ;     int i = 0
    ;     while i < 8
    ;         AddTextOption(CPP_SkillNames[i], GetLegendaryBonusText(i))
    ;         i += 1
    ;     EndWhile

    ;     SetCursorPosition(1)
    ;     AddEmptyOption()
    ;     while i < 18
    ;         AddTextOption(CPP_SkillNames[i], GetLegendaryBonusText(i))
    ;         i += 1
    ;     EndWhile

    elseif page == "Debug"
        SetCursorFillMode(TOP_TO_BOTTOM)

        AddHeaderOption("Legendary Skills")
        OID_DetectLegendary = AddTextOption("Sync Legendary Skills", "SYNC", CPP_Menu_HasDetectedLegendary.GetValueInt())

        AddEmptyOption()        
        AddHeaderOption("Cheats")

        OID_CheaterToggle = AddToggleOption("Cheats Enabled", debugCheaterToggle)

        if debugCheaterToggle == true
            OID_CheaterPerkPoints = AddSliderOption("Points Amount", debugCheaterPerkPoints, "{0}")
            OID_CheaterAdd = AddTextOption("Add Points", "ADD")
            OID_CheaterRemove = AddTextOption("Remove Points", "REMOVE")
        endif
    endif
EndEvent

Event OnOptionHighlight(int option)
    if option == OID_ModEnabled
        SetInfoText("Enable or disable the Complete Perk Points system. When disabled, no points will be granted.")
    elseif option == OID_LegendarySkillsEnabled
        SetInfoText("Controls whether legendary skills can still grant perk points.")
    elseif (option == OID_ShowNotifications)
        SetInfoText("Show notifications when points are awarded (leveling, skill progress, or dragon souls). Disabled in Player Level and Custom Skills modes.")
    elseif option == OID_ProgressionMode
        string a = "PERMANENT CHOICE.\n"
        string b = "Independent Skill Progression: Grants points when an individual skill increases by the configured interval.\n"
        string c = "Cumulative Skill Progression: Grants points based on the combined progress of multiple skills.\n"
        string d = "Player Level Progression: Grants points based on character level increases after confirming level-up."
        SetInfoText(a + b + c + d)
    elseif (option == OID_StartingLevel)
        SetInfoText("Level at which rewards begin. This level is included.")
    elseif (option == OID_LevelInterval)
        SetInfoText("Number of levels required to gain another point.")
    elseif (option == OID_MaxSkillLevel)
        SetInfoText("Maximum skill level used for reward calculation. Default is 100 unless using an uncapper.")
    elseif (option == OID_PointsMultiplier)
        SetInfoText("Multiplies points granted at each interval.")
    elseif option == OID_SpellSouls
        SetInfoText("Number of dragon souls required to gain points using the sacrifice spell.")
    elseif option == OID_SpellPoints
        SetInfoText("Points granted when the required number of souls is consumed.")
    elseif option == OID_DragonEnabled
        SetInfoText("Enable automatic point rewards based on dragon soul absorption.")
    elseif option == OID_DragonSouls
        SetInfoText("Number of dragon souls that must be absorbed to trigger a reward. Souls are not consumed.")
    elseif option == OID_DragonPoints
        SetInfoText("Points granted each time the absorption threshold is reached.")
    elseif option == OID_DetectLegendary
        SetInfoText("Synchronizes skills at the maximum level with the progression system.")
    elseif option == OID_AddMissingPoints
        SetInfoText("Adds points that were missed due to recent setting changes.")
    elseif option == OID_UndoAddedMissedPoints
        SetInfoText("Reverts points added during the last recalculation.")
    elseif option == OID_PerkPointsLevelsPreview
        SetInfoText("Shows upcoming levels where points will be granted.")
    elseif option == OID_PerkPointsPreview
        SetInfoText("Displays total points a single skill can generate at the maximum level.")
    elseif option == OID_PerkPointsExcess
        SetInfoText("Shows points currently deferred due to stricter settings. They will be balanced through future progression.")
    elseif option == OID_CustomSkills_Enabled
        SetInfoText("Enable progression rewards for Custom Skills.")
    elseif option == OID_CustomSkills_ProgressionMode
        SetInfoText("PERMANENT CHOICE.\nIndependent: Each skill progresses separately.\nCumulative: Grants points based on the combined progress of multiple custom skills.")
    elseif option == OID_CustomSkills_StartingLevel
        SetInfoText("Level at which a custom skill begins granting points. Includes this level.")
    elseif option == OID_CustomSkills_LevelInterval
        SetInfoText("Number of skill levels required before another perk point is granted.")
    elseif option == OID_CustomSkills_MaxLevel
        SetInfoText("Maximum skill level used for perk point calculation.")
    elseif option == OID_CustomSkills_PerkPointsMultiplier
        SetInfoText("Multiplies points granted at each interval.")

    endif
EndEvent

Event OnOptionMenuOpen(int option)
    if option == OID_ProgressionMode
        if CPP_Menu_HasSelectedProgression.GetValue() == 1
            return
        endif
        menuOptions = new string[3]
        menuOptions[0] = "Independent Skill Progression"
        menuOptions[1] = "Cumulative Skill Progression"
        menuOptions[2] = "Player Level Progression"
        SetMenuDialogOptions(menuOptions)
    
    elseif option == OID_CustomSkills_ProgressionMode
            if CPP_CustomSkills_HasSelectedProgression.GetValue() == 1
                return
            endif
        menuOptions = new string[2]
        menuOptions[0] = "Independent Skill Progression"
        menuOptions[1] = "Cumulative Skill Progression"
        SetMenuDialogOptions(menuOptions)
    endif
EndEvent

Event OnOptionMenuAccept(int option, int index)
    if option == OID_ProgressionMode
        if CPP_Menu_HasSelectedProgression.GetValue() == 1
            return
        endif

        if index >= 0
            CPP_Menu_HasSelectedProgression.SetValue(1)
            SetOptionFlags(OID_ProgressionMode, OPTION_FLAG_DISABLED)
        endif

        if index == 0 ;normal skill progression mode
                CPP_GlobalSkillMode_Enabled.SetValue(0)
                CPP_PlayerLevelMode_Enabled.SetValue(0)

        elseif index == 1 ;global skill level progression
                CPP_GlobalSkillMode_Enabled.SetValue(1)
                CPP_PlayerLevelMode_Enabled.SetValue(0)
                ResetLastSkillLevels()

        elseif index == 2 ; player level progresion
                CPP_GlobalSkillMode_Enabled.SetValue(0)
                CPP_PlayerLevelMode_Enabled.SetValue(1)
        endif

        SetMenuOptionValue(OID_ProgressionMode, GetProgressionMode())
        UpdateSettingsPreview()

    elseif option == OID_CustomSkills_ProgressionMode
        if CPP_CustomSkills_HasSelectedProgression.GetValue() == 1
                return
            endif

        if index >= 0
            CPP_CustomSkills_HasSelectedProgression.SetValue(1)
            SetOptionFlags(OID_CustomSkills_ProgressionMode, OPTION_FLAG_DISABLED)
        endif

        if index == 0 ; Independent
            CPP_CustomSkills_GlobalProgressionMode.SetValue(2)

        elseif index == 1 ; Cumulative
            CPP_CustomSkills_GlobalProgressionMode.SetValue(1)

        endif
        SetMenuOptionValue(OID_CustomSkills_ProgressionMode, GetCustomSkillsProgressionMode())
        UpdateSettingsPreview()
    endif
EndEvent

; string Function GetLegendaryBonusText(int skillIndex)
;     int legendaryCount = CPP_SkillLegendaryCount[skillIndex].GetValueInt()
;     int bonus = CPP_LegendaryPowerBonusValue.GetValueInt()

;     Return legendaryCount * bonus + "%"
; EndFunction


Function ResetLastSkillLevels()
    Actor playerRef = Game.GetPlayer()
    int i = 0
    while i < CPP_LastSkillLevel.Length
        CPP_LastSkillLevel[i].SetValueInt(playerRef.GetBaseActorValue(CPP_SkillNames[i]) as int)
        i += 1
    endwhile
EndFunction

string Function GetProgressionMode()
    if CPP_PlayerLevelMode_Enabled.GetValue() == 1
        return "Player Level Progression"
    elseif CPP_GlobalSkillMode_Enabled.GetValue() == 1
        return "Cumulative Skill Progression"
    else
        return "Independent Skill Progression"
    endif
EndFunction

string Function GetCustomSkillsProgressionMode()
    if CPP_CustomSkills_GlobalProgressionMode.GetValue() == 1
        return "Cumulative Skill Progression"
    elseif CPP_CustomSkills_GlobalProgressionMode.GetValue() == 0
        return "Independent Skill Progression"
    else
        return "Independent Skill Progression"
    endif
EndFunction

Event OnOptionSelect(int option)
    if option == OID_ModEnabled
        if CPP_ModEnabled.GetValue() == 1
            CPP_ModEnabled.SetValue(0)
        else
            CPP_ModEnabled.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_ModEnabled.GetValue())

    elseif option == OID_LegendarySkillsEnabled
        if CPP_LegendarySkillsEnabled.GetValue() == 1
            CPP_LegendarySkillsEnabled.SetValue(0)
        else
            CPP_LegendarySkillsEnabled.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_LegendarySkillsEnabled.GetValue())

    elseif option == OID_ShowNotifications
        if CPP_ShowNotifications.GetValue() == 1
            CPP_ShowNotifications.SetValue(0)
        else
            CPP_ShowNotifications.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_ShowNotifications.GetValue())
        
    elseif option == OID_AddMissingPoints
        AddMissingPoints()

    elseif option == OID_UndoAddedMissedPoints
        UndoAddedMissedPoints()

    elseif option == OID_DragonEnabled
        if CPP_DragonDeaths_Enabled.GetValue() == 1
            CPP_DragonDeaths_Enabled.SetValue(0)
        else
            CPP_DragonDeaths_Enabled.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_DragonDeaths_Enabled.GetValue())
    
    elseif option == OID_CustomSkills_Enabled
        if CPP_CustomSkills_Enabled.GetValue() == 1
            CPP_CustomSkills_Enabled.SetValue(0)
        else
            CPP_CustomSkills_Enabled.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_CustomSkills_Enabled.GetValue())

    elseif option == OID_CustomSkills_ProgressionMode
        if CPP_CustomSkills_GlobalProgressionMode.GetValue() == 1
            CPP_CustomSkills_GlobalProgressionMode.SetValue(0)
        else
            CPP_CustomSkills_GlobalProgressionMode.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_CustomSkills_GlobalProgressionMode.GetValue())

    elseif option == OID_DetectLegendary
        DetectLegendarySkills()
        CPP_Menu_HasDetectedLegendary.SetValue(1)
        SetOptionFlags(OID_DetectLegendary, OPTION_FLAG_DISABLED)

    ; elseif option == OID_LegendaryPowerBonusEnabled
    ;     if CPP_LegendaryPowerBonusEnabled.GetValue() == 1
    ;         CPP_LegendaryPowerBonusEnabled.SetValue(0)
    ;     else
    ;         CPP_LegendaryPowerBonusEnabled.SetValue(1)
    ;     endif
    ;     SetToggleOptionValue(option, CPP_LegendaryPowerBonusEnabled.GetValue())

    elseif option == OID_CheaterToggle
        debugCheaterToggle = !debugCheaterToggle
        SetToggleOptionValue(option, debugCheaterToggle)
        ForcePageReset()

    elseif option == OID_CheaterAdd
        Game.AddPerkPoints(debugCheaterPerkPoints as int)

        if debugCheaterPerkPoints > 1
            Debug.MessageBox("Added " + debugCheaterPerkPoints as int + " perk points.")

        elseif debugCheaterPerkPoints == 1
            Debug.MessageBox("Added a perk point.")
        endif

    elseif option == OID_CheaterRemove
        Game.ModPerkPoints(0 - debugCheaterPerkPoints as int)

        if debugCheaterPerkPoints > 1
            Debug.MessageBox("Removed " + debugCheaterPerkPoints as int+ " perk points.")

        elseif debugCheaterPerkPoints == 1
            Debug.MessageBox("Removed a perk point.")
        endif

    else
        int i = 0
        while i < OID_SkillsDisabled.Length
            if option == OID_SkillsDisabled[i]
                if CPP_SkillsDisabled[i].GetValue() == 0
                    CPP_SkillsDisabled[i].SetValue(1)
                else
                    CPP_SkillsDisabled[i].SetValue(0)
                endif
                SetToggleOptionValue(option, CPP_SkillsDisabled[i].GetValue())
            endIf
            i += 1
        endWhile
    endif
EndEvent



Event OnOptionSliderOpen(int option)
    if option == OID_StartingLevel
        SetSliderDialogStartValue(CPP_StartingLevel.GetValue())
        SetSliderDialogDefaultValue(25.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)
        
    elseif option == OID_LevelInterval
        SetSliderDialogStartValue(CPP_LevelInterval.GetValue())
        SetSliderDialogDefaultValue(25.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)
        
    elseif option == OID_MaxSkillLevel
        SetSliderDialogStartValue(CPP_MaxSkillLevel.GetValue())
        SetSliderDialogDefaultValue(100.0)
        SetSliderDialogRange(10.0, 1000.0)
        SetSliderDialogInterval(10.0)

    elseif (option == OID_PointsMultiplier)
        SetSliderDialogStartValue(CPP_PerkPointsMultiplier.GetValue())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)

    elseif (option == OID_SpellSouls)
        SetSliderDialogStartValue(CPP_Spell_SoulToPoint_SoulsNeeded.GetValue())
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)

    elseif (option == OID_SpellPoints)
        SetSliderDialogStartValue(CPP_Spell_SoulToPoint_Points.GetValue())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)

    elseif (option == OID_DragonSouls)
        SetSliderDialogStartValue(CPP_DragonDeaths_SoulsNeeded.GetValue())
        SetSliderDialogDefaultValue(20.0)
        SetSliderDialogRange(1.0, 200.0)
        SetSliderDialogInterval(1.0)

    elseif (option == OID_DragonPoints)
        SetSliderDialogStartValue(CPP_DragonDeaths_Points.GetValue())
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)
    
    elseif (option == OID_CustomSkills_StartingLevel)
        SetSliderDialogStartValue(CPP_CustomSkills_StartingLevel.GetValue())
        SetSliderDialogDefaultValue(50.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)

    elseif (option == OID_CustomSkills_LevelInterval)
        SetSliderDialogStartValue(CPP_CustomSkills_LevelInterval.GetValue())
        SetSliderDialogDefaultValue(50.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)

    elseif (option == OID_CustomSkills_MaxLevel)
        SetSliderDialogStartValue(CPP_CustomSkills_MaxLevel.GetValue())
        SetSliderDialogDefaultValue(100.0)
        SetSliderDialogRange(1.0, 1000.0)
        SetSliderDialogInterval(5.0)

    elseif (option == OID_CustomSkills_PerkPointsMultiplier)
        SetSliderDialogStartValue(CPP_CustomSkills_PerkPointsMultiplier.GetValue())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)

    ; elseif (option == OID_LegendaryPowerBonusValue)
    ;     SetSliderDialogStartValue(CPP_LegendaryPowerBonusValue.GetValue())
    ;     SetSliderDialogDefaultValue(10.0)
    ;     SetSliderDialogRange(1.0, 200.0)
    ;     SetSliderDialogInterval(1.0)

    elseif option == OID_CheaterPerkPoints
        SetSliderDialogStartValue(debugCheaterPerkPoints)
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(1.0, 100.0)
        SetSliderDialogInterval(1.0)
    endif
EndEvent



Event OnOptionSliderAccept(int option, float value)
    if option == OID_StartingLevel
        CPP_StartingLevel.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")
        UpdateSettingsPreview()
        
    elseif option == OID_LevelInterval  
        CPP_LevelInterval.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")
        UpdateSettingsPreview()
        
    elseif option == OID_MaxSkillLevel
        CPP_MaxSkillLevel.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")
        UpdateSettingsPreview()

    elseif (option == OID_PointsMultiplier)
        CPP_PerkPointsMultiplier.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")
        UpdateSettingsPreview()

    elseif (option == OID_SpellSouls)
        CPP_Spell_SoulToPoint_SoulsNeeded.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_SpellPoints)
        CPP_Spell_SoulToPoint_Points.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_DragonSouls)
        CPP_DragonDeaths_SoulsNeeded.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_DragonPoints)
        CPP_DragonDeaths_Points.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_CustomSkills_StartingLevel)
        CPP_CustomSkills_StartingLevel.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_CustomSkills_LevelInterval)
        CPP_CustomSkills_LevelInterval.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_CustomSkills_MaxLevel)
        CPP_CustomSkills_MaxLevel.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")

    elseif (option == OID_CustomSkills_PerkPointsMultiplier)
        CPP_CustomSkills_PerkPointsMultiplier.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")
    
    ; elseif (option == OID_LegendaryPowerBonusValue)
    ;     CPP_LegendaryPowerBonusValue.SetValue(value)
    ;     SetSliderOptionValue(option, value, "{0}")

    elseif option == OID_CheaterPerkPoints
        debugCheaterPerkPoints = value
        SetSliderOptionValue(option, value, "{0}")
        ForcePageReset()

    endif
EndEvent

function UpdateSettingsPreview()
    SetTextOptionValue(OID_PerkPointsLevelsPreview, GetPerkLevelsPreview())
    SetTextOptionValue(OID_PerkPointsPreview, GetPerkPointsPreview())
    SetTextOptionValue(OID_PerkPointsExcess, ExcessPointsCalculate())
endfunction

string Function GetPerkLevelsPreview()
    if CPP_GlobalSkillMode_Enabled.GetValueInt()
        return CPP_StartingLevel.GetValueInt() + " ..."
    endif
    int start = CPP_StartingLevel.GetValueInt()
    int interval = CPP_LevelInterval.GetValueInt()
    int max = CPP_MaxSkillLevel.GetValueInt()
    
    string preview = start + ""
    int nextLevel = start + interval
    int count = 1
    
    while nextLevel <= max && count < 5 ; Show first 5 levels
        preview += ", " + nextLevel
        nextLevel += interval
        count += 1
    endWhile
    
    if nextLevel < max
        preview += "..."
    endif
    
    return preview
EndFunction

int Function GetPerkPointsPreview()
    Actor Player = Game.GetPlayer()
    int start = CPP_StartingLevel.GetValueInt()
    int interval = CPP_LevelInterval.GetValueInt()
    int maxLevel = CPP_MaxSkillLevel.GetValueInt()

    int calculationBaseline = start - interval
    int perkPointsDeserved = (maxLevel - calculationBaseline) / interval
    perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
    
    return perkPointsDeserved
EndFunction

Function AddMissingPoints()

    if CPP_GlobalSkillMode_Enabled.GetValue()
        AddMissing_GlobalMode()
    elseif CPP_PlayerLevelMode_Enabled.GetValue()
        AddMissing_PlayerLevelMode()
    else 
        AddMissing_NormalMode()
    endif
    
EndFunction

Function AddMissing_GlobalMode()

    Actor playerRef = Game.GetPlayer()

    int totalProgress = 0
    int skillCount = CPP_SkillNames.Length
    int i = 0

    while i < skillCount

        if CPP_SkillsDisabled[i].GetValueInt() == 0

            int skillLevel = playerRef.GetBaseActorValue(CPP_SkillNames[i]) as int
            int lastLevel  = CPP_LastSkillLevel[i].GetValueInt()

            int gained = skillLevel - lastLevel
            if gained < 0
                gained = 0
            endif

            totalProgress += gained
        endif

        i += 1
    endwhile

    int levelInterval = CPP_LevelInterval.GetValueInt()
    int multiplier    = CPP_PerkPointsMultiplier.GetValueInt()

    int totalDeserved = (totalProgress / levelInterval) * multiplier
    int given         = CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt()
    totalMissing      = totalDeserved - given

    if totalMissing > 0
        CPP_GlobalSkillMode_PerkPointsEarned.SetValueInt(totalDeserved)
    endif

    GiveMissingPerkPointsWithMessage(totalMissing, totalDeserved)

EndFunction


Function AddMissing_PlayerLevelMode()

    Actor playerRef = Game.GetPlayer()

    int playerLevel   = playerRef.GetLevel()
    int startingLevel = CPP_StartingLevel.GetValueInt()
    int levelInterval = CPP_LevelInterval.GetValueInt()
    int multiplier    = CPP_PerkPointsMultiplier.GetValueInt()

    if playerLevel < startingLevel
        GiveMissingPerkPointsWithMessage(0, 0)
        return
    endif

    int baseline = startingLevel - levelInterval
    int pointsDeserved = ((playerLevel - baseline) / levelInterval) * multiplier
    int pointsEarned   = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()

    totalMissing = pointsDeserved - pointsEarned

    if totalMissing > 0
        CPP_PlayerLevelMode_PerkPointsEarned.SetValueInt(pointsDeserved)
    endif

    GiveMissingPerkPointsWithMessage(totalMissing, pointsDeserved)

EndFunction


Function AddMissing_NormalMode()

    Actor playerRef = Game.GetPlayer()

    int startingLevel = CPP_StartingLevel.GetValueInt()
    int levelInterval = CPP_LevelInterval.GetValueInt()
    int maxLevel      = CPP_MaxSkillLevel.GetValueInt()
    int multiplier    = CPP_PerkPointsMultiplier.GetValueInt()

    int baseline = startingLevel - levelInterval
    int totalDeserved = 0

    int skillCount = CPP_SkillNames.Length
    int i = 0

    while i < skillCount

        if CPP_SkillsDisabled[i].GetValueInt() == 0

            int skillLevel = playerRef.GetBaseActorValue(CPP_SkillNames[i]) as int
            int deserved = ((skillLevel - baseline) / levelInterval) * multiplier
            int current  = CPP_PerkPointsEarned[i].GetValueInt()

            if deserved > 0
                totalDeserved += deserved
            endif

            if deserved > current && deserved > 0
                totalMissing += (deserved - current)

                if skillLevel == maxLevel
                    CPP_PerkPointsEarned[i].SetValueInt(0)
                else
                    CPP_PerkPointsEarned[i].SetValueInt(deserved)
                endif
            endif

        endif

        i += 1
    endwhile

    GiveMissingPerkPointsWithMessage(totalMissing, totalDeserved)

EndFunction



Function GiveMissingPerkPointsWithMessage(int pointsToAdd, int totalPerkPointsDeserved)

    if pointsToAdd > 1
    Game.AddPerkPoints(pointsToAdd)
    Debug.MessageBox("Added " + pointsToAdd + " points.")

    elseif pointsToAdd == 1
        Game.AddPerkPoints(1)
        Debug.MessageBox("Added 1 point.")

    elseif pointsToAdd == 0
        Debug.MessageBox("No points added.")

    else
        int excessPoints = totalPerkPointsDeserved - pointsToAdd
        Debug.MessageBox("No points added. " + excessPoints + " points remain deferred.")
    endif

EndFunction



Function UndoAddedMissedPoints()

    if totalMissing <= 0
        Debug.MessageBox("No points to revert.")
        return
    endif

    Game.ModPerkPoints(-totalMissing)

    if totalMissing > 1
        Debug.MessageBox("Reverted " + totalMissing + " points.")
    else
        Debug.MessageBox("Reverted 1 point.")
    endif

    ; Restore saved values
    if CPP_PlayerLevelMode_Enabled.GetValueInt() == 1
        CPP_PlayerLevelMode_PerkPointsEarned.SetValueInt(savedPerkPointsEarnedPlayer)

    elseif CPP_GlobalSkillMode_Enabled.GetValueInt() == 1
        CPP_GlobalSkillMode_PerkPointsEarned.SetValueInt(savedPerkPointsEarnedGlobal)

    else
        int i = 0
        while i < CPP_SkillNames.Length
            CPP_PerkPointsEarned[i].SetValueInt(savedPerkPointsEarnedNormal[i])
            i += 1
        endwhile
    endif

    totalMissing = 0

EndFunction


string Function ExcessPointsCalculate()

    Actor Player = Game.GetPlayer()
    int startingLevel = CPP_StartingLevel.GetValueInt()
    int levelInterval = CPP_LevelInterval.GetValueInt()
    int calculationBaseline = startingLevel - levelInterval
    int multiplier = CPP_PerkPointsMultiplier.GetValueInt()

    int excessPoints = 0
    int i = 0

    if CPP_GlobalSkillMode_Enabled.GetValueInt() == 1

        int perkPointsDeserved = (CPP_GlobalSkillMode_LevelProgress.GetValueInt() / levelInterval) * multiplier
        int perkPointsEarned   = CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt()

        if perkPointsDeserved < perkPointsEarned
            excessPoints = perkPointsEarned - perkPointsDeserved
        endif


    elseif CPP_PlayerLevelMode_Enabled.GetValueInt() == 1

        int playerLevel = Player.GetLevel()
        if playerLevel < startingLevel
            return 0
        endif

        int perkPointsEarned = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()
        int perkPointsDeserved = ((playerLevel - calculationBaseline) / levelInterval) * multiplier

        if perkPointsDeserved < perkPointsEarned
            excessPoints = perkPointsEarned - perkPointsDeserved
        endif


    else ; NORMAL MODE

        while i < CPP_SkillNames.Length

            if CPP_SkillsDisabled[i].GetValueInt() == 0
                int skillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int

                if skillLevel >= startingLevel
                    int perkPointsDeserved = ((skillLevel - calculationBaseline) / levelInterval) * multiplier
                    int perkPointsEarned   = CPP_PerkPointsEarned[i].GetValueInt()

                    if perkPointsDeserved < perkPointsEarned
                        excessPoints += perkPointsEarned - perkPointsDeserved
                    endif
                endif
            endif

            i += 1
        endwhile

    endif

    return excessPoints
EndFunction


Function DetectLegendarySkills()
    if CPP_GlobalSkillMode_Enabled.GetValue() || CPP_PlayerLevelMode_Enabled.GetValue()
        Debug.MessageBox("This function is not available in the current progression mode.")
        return
    endif

    Actor Player = Game.GetPlayer()
    int maxLevel = CPP_MaxSkillLevel.GetValueInt()
    int legendaryCount = 0

    int i = 0
    while i < CPP_SkillNames.Length
        ; if CPP_SkillsDisabled[i].GetValue() == 0
            int skillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int
            if skillLevel == maxLevel
                CPP_PerkPointsEarned[i].SetValueInt(0)
                CPP_SkillLegendaryCount[i].SetValueInt(CPP_SkillLegendaryCount[i].GetValueInt() + 1)
                legendaryCount += 1
            endif
        ; endif
        i += 1
    endWhile
    if legendaryCount > 1
        Debug.MessageBox("Synchronized " + legendaryCount + " legendary skills.")
    elseif legendaryCount == 1
        Debug.MessageBox("Synchronized 1 legendary skill.")
    elseif legendaryCount == 0 
        Debug.MessageBox("No legendary skills required synchronization.")
    endif
    
EndFunction

    ; elseif page == "Skill Overview"
    ;     SetCursorFillMode(LEFT_TO_RIGHT)

    ;     AddHeaderOption("Perk Points From Skills")
    ;     AddTextOption("Alteration", CPP_PerkPointsEarned[0].GetValueInt())
    ;     AddEmptyOption()

    ;     AddTextOption("Conjuration", CPP_PerkPointsEarned[1].GetValueInt())
    ;     AddTextOption("Destruction", CPP_PerkPointsEarned[2].GetValueInt())
    ;     AddTextOption("Illusion", CPP_PerkPointsEarned[3].GetValueInt())
    ;     AddTextOption("Restoration", CPP_PerkPointsEarned[4].GetValueInt())
    ;     AddTextOption("Enchanting", CPP_PerkPointsEarned[5].GetValueInt())
    ;     AddTextOption("One-Handed", CPP_PerkPointsEarned[6].GetValueInt())
    ;     AddTextOption("Two-Handed", CPP_PerkPointsEarned[7].GetValueInt())
    ;     AddTextOption("Marksman", CPP_PerkPointsEarned[8].GetValueInt())
    ;     AddTextOption("Block", CPP_PerkPointsEarned[9].GetValueInt())
    ;     AddTextOption("Light Armor", CPP_PerkPointsEarned[10].GetValueInt())
    ;     AddTextOption("Heavy Armor", CPP_PerkPointsEarned[11].GetValueInt())
    ;     AddTextOption("Smithing", CPP_PerkPointsEarned[12].GetValueInt())
    ;     AddTextOption("Alchemy", CPP_PerkPointsEarned[13].GetValueInt())
    ;     AddTextOption("Sneak", CPP_PerkPointsEarned[14].GetValueInt())
    ;     AddTextOption("Lockpicking", CPP_PerkPointsEarned[15].GetValueInt())
    ;     AddTextOption("Pickpocket", CPP_PerkPointsEarned[16].GetValueInt())
    ;     AddTextOption("Speechcraft", CPP_PerkPointsEarned[17].GetValueInt())

    

    ; //// undo missed points
	; Actor Player = Game.GetPlayer()
    ; int totalPointsToRemove = 0
	; int i = 0

    ; ; Calculate total perks to remove based on stored values
    ; while i < CPP_PerkPointsEarned.Length
    ;     int storedPerks = CPP_PerkPointsEarned[i].GetValueInt()
    ;     if storedPerks > 0
    ;         totalPointsToRemove += storedPerks
    ;         ; Reset the stored value
    ;         CPP_PerkPointsEarned[i].SetValue(0)
    ;     endif
    ;     i += 1
    ; endwhile
    
    ; ; Remove the perks if any were stored
    ; if totalPointsToRemove > 0
    ;     int negativePerks = 0 - totalPointsToRemove
    ;     Game.ModPerkPoints(negativePerks)
    ;     Debug.MessageBox("Removed " + totalPointsToRemove + " perk points")
    ; else
    ;     Debug.MessageBox("No stored perk points to remove")
    ; endif