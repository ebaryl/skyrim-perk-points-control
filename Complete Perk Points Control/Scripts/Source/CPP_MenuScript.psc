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
int OID_CustomSkills_GlobalProgressionMode
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
    Pages[1] = "Skill Toggles"
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
        OID_LegendarySkillsEnabled = AddToggleOption("Enable Legendary Perk Points", CPP_LegendarySkillsEnabled.GetValue())
        OID_ShowNotifications = AddToggleOption("Show Notifications", CPP_ShowNotifications.GetValue())
        AddEmptyOption()

        AddHeaderOption("Progression Mode")
        OID_ProgressionMode = AddMenuOption("", GetProgressionMode(), CPP_Menu_HasSelectedProgression.GetValueInt())
        AddEmptyOption()
        
        AddHeaderOption("Points Award Settings")
        OID_StartingLevel = AddSliderOption("Starting Level", CPP_StartingLevel.GetValue(), "{0}")
        OID_LevelInterval = AddSliderOption("Level Interval", CPP_LevelInterval.GetValue(), "{0}")
        OID_MaxSkillLevel = AddSliderOption("Max Skill Level", CPP_MaxSkillLevel.GetValue(), "{0}")
        OID_PointsMultiplier = AddSliderOption("Perk Points Multiplier", CPP_PerkPointsMultiplier.GetValueInt(), "{0}")
        AddEmptyOption()

        AddHeaderOption("Spell Settings")
        OID_SpellSouls = AddSliderOption("Dragon Souls Required", CPP_Spell_SoulToPoint_SoulsNeeded.GetValue(), "{0}")
        OID_SpellPoints = AddSliderOption("Perk Points Gained", CPP_Spell_SoulToPoint_Points.GetValue(), "{0}")
        AddEmptyOption()

        AddHeaderOption("Dragon Soul Absorbtion Points")
        OID_DragonEnabled = AddToggleOption("Enable Absorbtion Points", CPP_DragonDeaths_Enabled.GetValue())
        OID_DragonSouls = AddSliderOption("Soul Absorbtions Required", CPP_DragonDeaths_SoulsNeeded.GetValue(), "{0}")
        OID_DragonPoints = AddSliderOption("Perk Points Gained", CPP_DragonDeaths_Points.GetValue(), "{0}")
        AddEmptyOption()

        SetCursorPosition(1) ; Move to right column
        
        AddHeaderOption("Initial Points Setup")
        OID_AddMissingPoints = AddTextOption("Add Missing Points", "Click to Add")
        OID_UndoAddedMissedPoints = AddTextOption("Undo Points", "Click to Undo")
        AddEmptyOption()
        AddEmptyOption()
        
        AddHeaderOption("Current Settings Preview")
        OID_PerkPointsLevelsPreview = AddTextOption("Points Awards At:", GetPerkLevelsPreview())
        OID_PerkPointsPreview = AddTextOption("Perk Points Per Skill:", GetPerkPointsPreview())
        OID_PerkPointsExcess = AddTextOption("Excess Perk Points:", ExcessPointsCalculate())

    elseif page == "Skill Toggles"
        SetCursorFillMode(TOP_TO_BOTTOM)
        
        OID_SkillsDisabled = new int[18]

        AddEmptyOption()
        AddHeaderOption("Select To Disable")
        AddEmptyOption()

        int i = 0
        while i < 8
            OID_SkillsDisabled[i] = AddToggleOption(CPP_SkillNames[i], CPP_SkillsDisabled[i].GetValue())
            i += 1
        EndWhile

        SetCursorPosition(1)
        AddEmptyOption()
        while i < 18
            OID_SkillsDisabled[i] = AddToggleOption(CPP_SkillNames[i], CPP_SkillsDisabled[i].GetValue())
            i += 1
        EndWhile

    elseif page =="Custom Skills"
        bool pluginActive = (CPP_CustomSkills_MCMEnabled.GetValueInt() == 1)
        int flags = OPTION_FLAG_NONE
        
        SetCursorFillMode(TOP_TO_BOTTOM)

        AddEmptyOption()
        if (pluginActive)
            AddHeaderOption("Custom Skills")
        else
            AddHeaderOption("SKSE plugin not loaded")
            flags = OPTION_FLAG_DISABLED
        endif
        AddEmptyOption()

        OID_CustomSkills_Enabled = AddToggleOption("Enable Custom Skill Points", CPP_CustomSkills_Enabled.GetValueInt(), flags)
        OID_CustomSkills_GlobalProgressionMode = AddToggleOption("Cumulative Skill Progression", CPP_CustomSkills_GlobalProgressionMode.GetValueInt(), flags)
        OID_CustomSkills_StartingLevel = AddSliderOption("Starting Level", CPP_CustomSkills_StartingLevel.GetValueInt(), "{0}", flags)
        OID_CustomSkills_LevelInterval = AddSliderOption("Level Interval", CPP_CustomSkills_LevelInterval.GetValueInt(), "{0}", flags)
        OID_CustomSkills_MaxLevel = AddSliderOption("Max Skill Level", CPP_CustomSkills_MaxLevel.GetValueInt(), "{0}", flags)
        OID_CustomSkills_PerkPointsMultiplier = AddSliderOption("Perk Points Multiplier", CPP_CustomSkills_PerkPointsMultiplier.GetValueInt(), "{0}", flags)
        
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
        OID_DetectLegendary = AddTextOption("Detect Legendary Skills", "Detect", CPP_Menu_HasDetectedLegendary.GetValueInt())

        AddEmptyOption()        
        AddHeaderOption("Cheats")

        OID_CheaterToggle = AddToggleOption("Enable Cheats", debugCheaterToggle)

        if debugCheaterToggle == true
            OID_CheaterPerkPoints = AddSliderOption("Perk Points", debugCheaterPerkPoints, "{0}")
            OID_CheaterAdd = AddTextOption("Add Points", "Click to Add")
            OID_CheaterRemove = AddTextOption("Remove Points", "Click to Remove")
        endif
    endif
EndEvent

Event OnOptionHighlight(int option)
    if (option == OID_ShowNotifications)
        SetInfoText("Toggle notifications when perk points are awarded (e.g., from leveling up, skill progress, or dragon souls). Notifications are disabled for Player Level Progression and Custom Skills.")
    
    elseif option == OID_ProgressionMode
        string aa = "PERMANENT CHOICE. "
        string a = "Independent Skill Progression: Grants a perk point when any single skill increases by the set amount. "
        string b = "Cumulative Skill Progression: Grants a perk point when the total combined skill level increases by the set amount. "
        string c = "Player Level: Grants a perk point each time your character levels up by the set amount AFTER you select stats and close level-up menu."
        SetInfoText(aa + a + b + c)

    elseif option == OID_LegendarySkillsEnabled
        SetInfoText("Controls whether legendary skills can still grant perk points.")
    elseif (option == OID_StartingLevel)
        SetInfoText("The player level or skill level at which you start receiving perk points. Includes this level.")
    elseif (option == OID_LevelInterval)
        SetInfoText("Number of levels to gain before receiving another perk point. E.g., 5 means every 5 levels.")
    elseif (option == OID_MaxSkillLevel)
        SetInfoText("The skill level at which you stop receiving points. Should match your skill cap. (Default is 100 unless using a skill uncapper.)")
    elseif (option == OID_PointsMultiplier)
        SetInfoText("Multiplies the number of perk points granted at each interval. E.g., 2 gives double points.")
    elseif option == OID_SpellSouls
        SetInfoText("Sets how many dragon souls are needed to gain perk points using the conversion spell.")
    elseif option == OID_SpellPoints
        SetInfoText("Sets how many perk points are gained when the required number of dragon souls is consumed by the spell.")
    elseif option == OID_DragonEnabled
        SetInfoText("Enable or disable automatic perk point rewards based on dragon soul absorption.")
    elseif option == OID_DragonSouls
        SetInfoText("Sets how many dragon souls must be absorbed to earn perk points passively. Souls are not consumed. Example: 30 = 1 point every 30 dragon souls.")
    elseif option == OID_DragonPoints
        SetInfoText("Sets how many perk points are awarded each time the required number of dragon souls is absorbed.")
    elseif option == OID_DetectLegendary
        SetInfoText("For independent skill progression only. Detects maxed-out skills based on your max level setting.")
    elseif option == OID_AddMissingPoints
        SetInfoText("Adds any missed perk points due to changed settings (e.g., lowering starting level, reducing the level interval, or increasing the points multiplier).")
    elseif option == OID_UndoAddedMissedPoints
        SetInfoText("Removes previously added points if you changed your mind afterward.")
    elseif option == OID_PerkPointsLevelsPreview
        SetInfoText("Shows a preview of the first few levels and when you'll receive perk points. Useful for planning.")
    elseif option == OID_PerkPointsPreview
        SetInfoText("Displays how many perk points you'll earn for a single skill if you level it to the maximum skill level.")
    elseif option == OID_PerkPointsExcess
        SetInfoText("Shows how many perk points are temporarily withheld due to reduced settings (e.g., higher level interval or lower multiplier). These points will be balanced out over future levels.")
    elseif option == OID_CustomSkills_Enabled
        SetInfoText("Enables or disables the Custom Skills perk point progression system.")
    elseif option == OID_CustomSkills_GlobalProgressionMode
        SetInfoText("When enabled, perk point progression is shared globally across all custom skills instead of being tracked individually per skill.")
    elseif option == OID_CustomSkills_StartingLevel
        SetInfoText("The skill level at which a custom skill begins granting perk points. Includes this level.")
    elseif option == OID_CustomSkills_LevelInterval
        SetInfoText("Number of skill levels required before another perk point is granted. Example: 5 = 1 point every 5 skill levels.")
    elseif option == OID_CustomSkills_MaxLevel
        SetInfoText("The maximum skill level used for perk point calculation. Should match the custom skill cap.")
    elseif option == OID_CustomSkills_PerkPointsMultiplier
        SetInfoText("Multiplies the number of perk points awarded at each interval. Example: 2 grants double perk points.")

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
        menuOptions[2] = "Player Level"
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
        return "Player Level"
    elseif CPP_GlobalSkillMode_Enabled.GetValue() == 1
        return "Cumulative Skill Progression"
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

    elseif option == OID_CustomSkills_GlobalProgressionMode
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
        Debug.MessageBox("Added " + pointsToAdd + " perk points based on current skill levels.")

    elseif pointsToAdd == 1
        Game.AddPerkPoints(1)
        Debug.MessageBox("Added a perk point based on current skill levels.")

    elseif pointsToAdd == 0
        Debug.MessageBox("No perk points added.")

    else
        int excessPoints = totalPerkPointsDeserved - pointsToAdd
        Debug.MessageBox("No perk points added. You still have " + excessPoints + " excess perk point(s).")
    endif

EndFunction



Function UndoAddedMissedPoints()

    if totalMissing <= 0
        Debug.MessageBox("No perk points were added, so nothing was removed.")
        return
    endif

    Game.ModPerkPoints(-totalMissing)

    if totalMissing > 1
        Debug.MessageBox("Removed " + totalMissing + " perk points.")
    else
        Debug.MessageBox("Removed a perk point.")
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
        Debug.MessageBox("I can't do it in this progression mode.")
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
        Debug.MessageBox("Detected " + legendaryCount + " legendary skills. Settings updated.")
    elseif legendaryCount == 1
        Debug.MessageBox("Detected a legendary skill. Settings updated.")
    elseif legendaryCount == 0 
        Debug.MessageBox("Detected no legendary skills.")
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