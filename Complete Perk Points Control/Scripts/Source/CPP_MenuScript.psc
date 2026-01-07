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
GlobalVariable Property CPP_PlayerLevelMode_Enabled auto
GlobalVariable Property CPP_PlayerLevelMode_PerkPointsEarned auto
GlobalVariable Property CPP_PerkPointsMultiplier auto
GlobalVariable Property CPP_Spell_SoulToPoint_SoulsNeeded auto
GlobalVariable Property CPP_Spell_SoulToPoint_Points auto
GlobalVariable Property CPP_DragonDeaths_Enabled auto
GlobalVariable Property CPP_DragonDeaths_SoulsNeeded auto
GlobalVariable Property CPP_DragonDeaths_Points auto
GlobalVariable Property CPP_Menu_HasSelectedProgression auto
GlobalVariable Property CPP_Menu_HasDetectedLegendary auto
Message Property CPP_MessageBox_Confirm auto

int totalPointsToAdd = 0
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
int OID_StartingLevel
int OID_LevelInterval  
int OID_MaxSkillLevel
int OID_ShowNotifications
int OID_AddMissedPoints
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



Event OnConfigInit()
    ModName = "Complete Perk Points Control"
    Pages = new string[3]
    Pages[0] = "General"
    Pages[1] = "Skill Toggles"
    ; Pages[1] = "Skill Overview"
    Pages[2] = "Debug"
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
        OID_ShowNotifications = AddToggleOption("Show Notifications", CPP_ShowNotifications.GetValue())
        AddEmptyOption()

        AddHeaderOption("Progression Mode")
        ;OID_GlobalSkillProgressionMode = AddToggleOption("Use Global Skill Counter", CPP_GlobalSkillMode_Enabled.GetValue())
        OID_ProgressionMode = AddMenuOption("", GetProgressionMode())
        ;OID_PlayerLevelProgressionMode = AddToggleOption("Use Player Level Counter", CPP_GlobalSkillMode_Enabled.GetValue())
        AddEmptyOption()
        
        AddHeaderOption("Points Award Settings")
        OID_StartingLevel = AddSliderOption("Starting Level", CPP_StartingLevel.GetValue(), "{0}")
        OID_LevelInterval = AddSliderOption("Level Interval", CPP_LevelInterval.GetValue(), "{0}")
        OID_MaxSkillLevel = AddSliderOption("Max Skill Level", CPP_MaxSkillLevel.GetValue(), "{0}")
        OID_PointsMultiplier = AddSliderOption("Points Multiplier", CPP_PerkPointsMultiplier.GetValueInt(), "{0}")
        AddEmptyOption()

        AddHeaderOption("Spell Settings")
        OID_SpellSouls = AddSliderOption("Dragon Souls Required", CPP_Spell_SoulToPoint_SoulsNeeded.GetValue(), "{0}")
        OID_SpellPoints = AddSliderOption("Perk Points Gained", CPP_Spell_SoulToPoint_Points.GetValue(), "{0}")
        AddEmptyOption()

        AddHeaderOption("Dragon Soul Absorbtion Points")
        OID_DragonEnabled = AddToggleOption("Enable", CPP_DragonDeaths_Enabled.GetValue())
        OID_DragonSouls = AddSliderOption("Soul Absorbtions Required", CPP_DragonDeaths_SoulsNeeded.GetValue(), "{0}")
        OID_DragonPoints = AddSliderOption("Perk Points Gained", CPP_DragonDeaths_Points.GetValue(), "{0}")
        AddEmptyOption()

        SetCursorPosition(1) ; Move to right column
        
        AddHeaderOption("Initial Points Setup")
        OID_AddMissedPoints = AddTextOption("Add Missing Points", "Click to Add")
        OID_UndoAddedMissedPoints = AddTextOption("Undo Points", "Click to Undo")
        AddEmptyOption()

        ;AddHeaderOption("Display Settings")
        ;OID_ShowNotifications = AddToggleOption("Show Notifications", CPP_ShowNotifications.GetValue())
        ;AddEmptyOption()
        
        AddHeaderOption("Current Settings Preview")
        OID_PerkPointsLevelsPreview = AddTextOption("Points Awards At:", GetPerkLevelsPreview())
        OID_PerkPointsPreview = AddTextOption("Perk Points Per Skill:", GetPerkPointsPreview())
        OID_PerkPointsExcess = AddTextOption("Excess Perk Points:", ExcessPointsCalculate())

        ; // DISABLE SETTINGS
        ; int CPP_MCM_UsedDetectLegendary
        
        

    elseif page == "Skill Toggles"
        SetCursorFillMode(TOP_TO_BOTTOM)
        
        OID_SkillsDisabled = new int[18]

        AddHeaderOption("Select To Disable")
        AddEmptyOption()
        OID_SkillsDisabled[0] = AddToggleOption("Alteration", CPP_SkillsDisabled[0].GetValue())
        OID_SkillsDisabled[1] = AddToggleOption("Conjuration", CPP_SkillsDisabled[1].GetValue())
        OID_SkillsDisabled[2] = AddToggleOption("Destruction", CPP_SkillsDisabled[2].GetValue())
        OID_SkillsDisabled[3] = AddToggleOption("Illusion", CPP_SkillsDisabled[3].GetValue())
        OID_SkillsDisabled[4] = AddToggleOption("Restoration", CPP_SkillsDisabled[4].GetValue())
        OID_SkillsDisabled[5] = AddToggleOption("Enchanting", CPP_SkillsDisabled[5].GetValue())
        OID_SkillsDisabled[6] = AddToggleOption("One-Handed", CPP_SkillsDisabled[6].GetValue())
        OID_SkillsDisabled[7] = AddToggleOption("Two-Handed", CPP_SkillsDisabled[7].GetValue())

        SetCursorPosition(1)
        OID_SkillsDisabled[8] = AddToggleOption("Marksman", CPP_SkillsDisabled[8].GetValue())
        OID_SkillsDisabled[9] = AddToggleOption("Block", CPP_SkillsDisabled[9].GetValue())
        OID_SkillsDisabled[10] = AddToggleOption("Light Armor", CPP_SkillsDisabled[10].GetValue())
        OID_SkillsDisabled[11] = AddToggleOption("Heavy Armor", CPP_SkillsDisabled[11].GetValue())
        OID_SkillsDisabled[12] = AddToggleOption("Smithing", CPP_SkillsDisabled[12].GetValue())
        OID_SkillsDisabled[13] = AddToggleOption("Alchemy", CPP_SkillsDisabled[13].GetValue())
        OID_SkillsDisabled[14] = AddToggleOption("Sneak", CPP_SkillsDisabled[14].GetValue())
        OID_SkillsDisabled[15] = AddToggleOption("Lockpicking", CPP_SkillsDisabled[15].GetValue())
        OID_SkillsDisabled[16] = AddToggleOption("Pickpocket", CPP_SkillsDisabled[16].GetValue())
        OID_SkillsDisabled[17] = AddToggleOption("Speechcraft", CPP_SkillsDisabled[17].GetValue())





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




    ElseIf page == "Debug"
        SetCursorFillMode(TOP_TO_BOTTOM)

        AddHeaderOption("Legendary Skills")
        OID_DetectLegendary = AddTextOption("Detect Legendary Skills", "Detect")

        AddEmptyOption()        
        AddHeaderOption("Cheats")

        OID_CheaterToggle = AddToggleOption("Enable Cheats", debugCheaterToggle)

        if debugCheaterToggle == true
            OID_CheaterPerkPoints = AddSliderOption("Perk Points", debugCheaterPerkPoints, "{0}")
            OID_CheaterAdd = AddTextOption("Add Points", "Click to Add")
            OID_CheaterRemove = AddTextOption("Remove Points", "Click to Remove")
        endif

        ; // DISABLE

        if CPP_Menu_HasDetectedLegendary.GetValue()
            SetOptionFlags(OID_DetectLegendary, OPTION_FLAG_DISABLED, true)
        endif
    EndIf
EndEvent

Event OnOptionHighlight(int option)
    if (option == OID_ShowNotifications)
        SetInfoText("Toggle notifications when perk points are awarded (e.g., from leveling up, skill progress, or dragon souls).")
    
    elseif option == OID_ProgressionMode
        string aa = "PERMANENT CHOICE. "
        string a = "Independent Skill Progression: Grants a perk point when any single skill increases by the set amount. "
        string b = "Cumulative Skill Progression: Grants a perk point when the total combined skill level increases by the set amount. "
        string c = "Player Level Beta: Grants a perk point each time your character levels up by the set amount after you close level-up menu."
        SetInfoText(aa + a + b + c)

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
        SetInfoText("Enable or disable automatic perk point rewards based on dragon soul absorption (from dragon kills).")
    elseif option == OID_DragonSouls
        SetInfoText("Sets how many dragon souls must be absorbed to earn perk points passively. Souls are not consumed. Example: 30 = 1 point every 30 dragon souls.")
    elseif option == OID_DragonPoints
        SetInfoText("Sets how many perk points are awarded each time the required number of dragon souls is absorbed.")
    elseif option == OID_DetectLegendary
        SetInfoText("For independent skill progression only. Detects maxed-out skills based on your max level setting.")
    elseif option == OID_AddMissedPoints
        SetInfoText("Adds any missed perk points due to changed settings (e.g., lowering starting level, reducing the level interval, or increasing the points multiplier).")
        ; SetInfoText("Adds missed perk points if you installed the mod mid-save or changed the settings.")
    elseif option == OID_UndoAddedMissedPoints
        SetInfoText("Removes previously added points if you changed your mind afterward.")
        ;SetInfoText("Undo the last addition of missed perk points.")
    elseif option == OID_PerkPointsLevelsPreview
        SetInfoText("Shows a preview of the first few levels and when you'll receive perk points. Useful for planning.")
    elseif option == OID_PerkPointsPreview
        SetInfoText("Displays how many perk points you'll earn for a single skill if you level it to the maximum skill level.")
    elseif option == OID_PerkPointsExcess
        SetInfoText("Shows how many perk points are temporarily withheld due to reduced settings (e.g., higher level interval or lower multiplier). These points will be balanced out over future levels.")
    endif
EndEvent

string Function checkFlag(string OID_option)
    if OID_option == "OID_ProgressionMode"
        if CPP_Menu_HasSelectedProgression.GetValue()
            return "OPTION_FLAG_DISABLED"
    elseif OID_option == "OID_DetectLegendary"
        if CPP_Menu_HasDetectedLegendary.GetValue()
            return "OPTION_FLAG_DISABLED"
    endif
EndFunction

Event OnOptionMenuOpen(int option)
    if option == OID_ProgressionMode
        menuOptions = new string[3]
        menuOptions[0] = "Independent Skill Progression" ; single skill treshold
        menuOptions[1] = "Cumulative Skill Progression"
        menuOptions[2] = "Player Level Beta"
        SetMenuDialogOptions(menuOptions)
    endif
EndEvent

Event OnOptionMenuAccept(int option, int index)
    if option == OID_ProgressionMode
        if index >= 0
            CPP_Menu_HasSelectedProgression.SetValue(1)
            SetOptionFlags(OID_ProgressionMode, OPTION_FLAG_DISABLED, true)
        endif

        if index == 0 ;normal skill progression mode - needs to be for example 5 levels of marksman or 5 levels of block
                CPP_GlobalSkillMode_Enabled.SetValue(0)
                CPP_PlayerLevelMode_Enabled.SetValue(0)
                ; Debug.MessageBox("You will now gain additional perk points based on your progress in a single skill.")

        elseif index == 1 ;global skill level progression - doesnt matter if you level 3 of alchemy and 2 of marksman, it still counts as 5 levels
                CPP_GlobalSkillMode_Enabled.SetValue(1)
                CPP_PlayerLevelMode_Enabled.SetValue(0)
                ; Debug.MessageBox("You will now gain additional perk points based on the total progress across all skills.")

        elseif index == 2 ; player level progresion - based on player level not skill levels, you gain additional perk points on player level ups
                CPP_GlobalSkillMode_Enabled.SetValue(0)
                CPP_PlayerLevelMode_Enabled.SetValue(1)
                ; Debug.MessageBox("You'll gain additional perk points when your character level increases AFTER you close the stats menu")
                Debug.MessageBox("Extra perk points are awarded after you level up, select stats and close the menu.")

        endif

        SetMenuOptionValue(OID_ProgressionMode, GetProgressionMode())
        UpdateSettingsPreview()
    endif
EndEvent


string Function GetProgressionMode()
    if CPP_GlobalSkillMode_Enabled.GetValue() == 1
        CPP_PlayerLevelMode_Enabled.SetValue(0)
        return "Cumulative Skill Progression"
    elseif CPP_PlayerLevelMode_Enabled.GetValue() == 1
        CPP_GlobalSkillMode_Enabled.SetValue(0)
        return "Player Level Beta"
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
        
    ; elseif option == OID_GlobalSkillProgressionMode
    ;     if CPP_GlobalSkillMode_Enabled.GetValue() == 1
    ;         CPP_GlobalSkillMode_Enabled.SetValue(0)
    ;     else
    ;         CPP_GlobalSkillMode_Enabled.SetValue(1)
    ;     endif

    ;     int buttonIndex = CPP_MessageBox_Confirm.Show()
    ;     if buttonIndex == 0
    ;         CPP_Menu_HasSelectedProgression.SetValue(1)
    ;         SetToggleOptionValue(option, CPP_GlobalSkillMode_Enabled.GetValue())
    ;     endif

    elseif option == OID_ShowNotifications
        if CPP_ShowNotifications.GetValue() == 1
            CPP_ShowNotifications.SetValue(0)
        else
            CPP_ShowNotifications.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_ShowNotifications.GetValue())
        CPP_Menu_HasSelectedProgression.SetValue(1)
        
    elseif option == OID_AddMissedPoints
        AddMissedPoints()

    elseif option == OID_UndoAddedMissedPoints
        UndoAddedMissedPoints()

    elseif option == OID_DragonEnabled
        if CPP_DragonDeaths_Enabled.GetValue() == 1
            CPP_DragonDeaths_Enabled.SetValue(0)
        else
            CPP_DragonDeaths_Enabled.SetValue(1)
        endif
        SetToggleOptionValue(option, CPP_DragonDeaths_Enabled.GetValue())

    elseif option == OID_DetectLegendary
        DetectLegendarySkills()
        CPP_Menu_HasDetectedLegendary.SetValue(1)
        SetOptionFlags(OID_DetectLegendary, OPTION_FLAG_DISABLED, true)

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
        SetSliderDialogInterval(1)

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
        SetSliderOptionValue(OID_PointsMultiplier, value, "{0}")
        UpdateSettingsPreview()

    elseif (option == OID_SpellSouls)
        CPP_Spell_SoulToPoint_SoulsNeeded.SetValue(value)
        SetSliderOptionValue(OID_SpellSouls, value, "{0}")

    elseif (option == OID_SpellPoints)
        CPP_Spell_SoulToPoint_Points.SetValue(value)
        SetSliderOptionValue(OID_SpellPoints, value, "{0}")

    elseif (option == OID_DragonSouls)
        CPP_DragonDeaths_SoulsNeeded.SetValue(value)
        SetSliderOptionValue(OID_DragonSouls, value, "{0}")

    elseif (option == OID_DragonPoints)
        CPP_DragonDeaths_Points.SetValue(value)
        SetSliderOptionValue(OID_DragonPoints, value, "{0}")

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

; Helper function to show perk level preview
string Function GetPerkLevelsPreview()
    if CPP_GlobalSkillMode_Enabled.GetValue()
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

    ; if CPP_GlobalSkillMode_Enabled.GetValue()
    int calculationBaseline = start - interval
    int perkPointsDeserved = (maxLevel - calculationBaseline) / interval
    perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
    return perkPointsDeserved


    ; elseif CPP_PlayerLevelMode_Enabled.GetValue()
    ;     int calculationBaseline = start - interval
    ;     int perkPointsDeserved = (maxLevel - calculationBaseline) / interval
    ;     perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
    
    ; else
    ;     int calculationBaseline = start - interval
    ;     int perkPointsDeserved = (maxLevel - calculationBaseline) / interval
    ;     perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
    ;     return perkPointsDeserved
; 
    ; endif
EndFunction

;elseIf option == PerksFromStartOption
Function AddMissedPoints()

    if CPP_GlobalSkillMode_Enabled.GetValue()
        AddMissedPointsGlobal()
    elseif CPP_PlayerLevelMode_Enabled.GetValue()
        AddMissedPointsPlayerLevel()
    else 
        AddMissedPointsNormal()
    endif
    
EndFunction

Function AddMissedPointsGlobal()
    Actor player = Game.GetPlayer()

    int i = 0
    int globalLevelCount = 0
    int startingLevel = CPP_StartingLevel.GetValueInt()

    while i < CPP_SkillNames.Length
        int currentLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int
        if (CPP_SkillsDisabled[i].GetValue() == 0 && currentLevel >= startingLevel)
            globalLevelCount +=  currentLevel - startingLevel + 1 ; globalLevel += skillLevel
        endIf
        i += 1
    endwhile

    int perkPointsDeserved = globalLevelCount / CPP_LevelInterval.GetValueInt()
    perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
    ; ile gracz powinien miec ogolnie perk pointow
    totalPointsToAdd = perkPointsDeserved - CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt()
    ; ile wiecej powinno sie dodac

    if totalPointsToAdd > 1
        Game.AddPerkPoints(totalPointsToAdd)
        CPP_GlobalSkillMode_PerkPointsEarned.SetValue(perkPointsDeserved)
        Debug.MessageBox("Added " + totalPointsToAdd + " perk points based on current skill levels.")
    
    elseif totalPointsToAdd == 1
        Game.AddPerkPoints(totalPointsToAdd)
        CPP_GlobalSkillMode_PerkPointsEarned.SetValue(perkPointsDeserved)
        Debug.MessageBox("Added a perk point based on current skill levels.")

    elseif totalPointsToAdd == 0
        Debug.MessageBox("No perk points added.")

    else
        int excessPoints = perkPointsDeserved - CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt();
        Debug.MessageBox("No perk points added, you still have " + excessPoints + " excess points.")

    endif

    ; Debug.MessageBox("deserved = " + perkPointsDeserved + " totaltoadd = " + totalPointsToAdd + " globallevelcount = " + globalLevelCount + "earned = " + CPP_GlobalSkillMode_PerkPointsEarned.GetValue())
EndFunction

Function AddMissedPointsPlayerLevel()
    int playerLevel = Game.GetPlayer().GetLevel()
    int startingLevel = CPP_StartingLevel.GetValueInt()
    int levelInterval = CPP_LevelInterval.GetValueInt()

    savedPerkPointsEarnedPlayer = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()

    if playerLevel >= startingLevel

        int calculationBaseline = startingLevel - levelInterval
        int pointsDeserved = (playerLevel - calculationBaseline) / levelInterval
        pointsDeserved = pointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
        int pointsEarned = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()
        savedPerkPointsEarnedGlobal = pointsEarned
        ; Debug.MessageBox("deserved = " + pointsDeserved + "earned = " + pointsEarned + "calcbaseline = " + calculationBaseline + "playerlevel" + playerLevel)

        if pointsEarned < pointsDeserved
            totalPointsToAdd = pointsDeserved - pointsEarned

            CPP_PlayerLevelMode_PerkPointsEarned.SetValue(pointsDeserved)

            Game.AddPerkPoints(totalPointsToAdd)

            if totalPointsToAdd > 1
                Debug.MessageBox("Added " + totalPointsToAdd + " perk points based on current skill levels.")

            elseif totalPointsToAdd == 1
                Debug.MessageBox("Added a perk point based on current skill levels.")

            elseif totalPointsToAdd == 0
                Debug.MessageBox("No perk points added.")

            else
                int excessPoints = pointsDeserved - totalPointsToAdd
                Debug.MessageBox("No perk points added. You still have " + excessPoints + " excess perk point(s).")
            endIf

        endif
    endif
EndFunction

Function AddMissedPointsNormal()
    Actor player = Game.GetPlayer()

    int calculationBaseline = CPP_StartingLevel.GetValueInt() - CPP_LevelInterval.GetValueInt()
    int totalPerkPointsDeserved = 0
	int i = 0

    while i < CPP_SkillNames.Length
        savedPerkPointsEarnedNormal = new int[18]
        savedPerkPointsEarnedNormal[i] = CPP_PerkPointsEarned[i].GetValueInt()
        i += 1
    endwhile

    i = 0

	while i < CPP_SkillNames.Length
        if CPP_SkillsDisabled[i].GetValue() == 0
            int skillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int
            int perkPointsDeserved = (skillLevel - calculationBaseline) / CPP_LevelInterval.GetValueInt()
            perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()

            totalPerkPointsDeserved += perkPointsDeserved

            if perkPointsDeserved > 0
                CPP_PerkPointsEarned[i].SetValue(perkPointsDeserved)
                totalPointsToAdd += perkPointsDeserved

            else
                CPP_PerkPointsEarned[i].SetValue(0)

            endIf
        endIf
		i += 1
	endwhile

    if totalPointsToAdd > 1
        Game.AddPerkPoints(totalPointsToAdd)
        Debug.MessageBox("Added " + totalPointsToAdd + " perk points based on current skill levels.")

    elseif totalPointsToAdd == 1
        Game.AddPerkPoints(totalPointsToAdd)
        Debug.MessageBox("Added a perk point based on current skill levels.")

    elseif totalPointsToAdd == 0
        Debug.MessageBox("No perk points added.")

    else
        int excessPoints = totalPerkPointsDeserved - totalPointsToAdd
        Debug.MessageBox("No perk points added. You still have " + excessPoints + " excess perk point(s).")
	endIf
EndFunction


Function UndoAddedMissedPoints()
    int totalPointsToRemove = 0 - totalPointsToAdd

    if totalPointsToAdd > 1
        Game.ModPerkPoints(totalPointsToRemove)
        Debug.MessageBox("Removed " + totalPointsToAdd + " perk points.")

    elseif totalPointsToAdd == 1
        Game.ModPerkPoints(totalPointsToRemove)
        Debug.MessageBox("Removed a perk point.")

    else
        Debug.MessageBox("No perk points were added, so nothing was removed.")

    endIf

    totalPointsToAdd = 0

    if CPP_GlobalSkillMode_Enabled.GetValue()
        CPP_GlobalSkillMode_PerkPointsEarned.SetValue(savedPerkPointsEarnedGlobal)
    elseif CPP_PlayerLevelMode_Enabled.GetValue()
        CPP_PlayerLevelMode_PerkPointsEarned.SetValue(savedPerkPointsEarnedPlayer)
    else ; normal mode
        int i = 0
        while i < CPP_SkillNames.Length
            CPP_PerkPointsEarned[i].SetValue(savedPerkPointsEarnedNormal[i])
            i += 1
        endwhile
    endif

EndFunction

string Function ExcessPointsCalculate()
    Actor Player = Game.GetPlayer()
    int startingLevel = CPP_StartingLevel.GetValueInt()
    int levelInterval = CPP_LevelInterval.GetValueInt()
    int calculationBaseline = startingLevel - levelInterval
    int excessPoints = 0
    int i = 0

    if CPP_GlobalSkillMode_Enabled.GetValue()
        int effectiveSkillLevelSum = 0

        while i < CPP_SkillNames.Length
            int skillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int
            if CPP_SkillsDisabled[i].GetValue() == 0 && skillLevel >= startingLevel
                effectiveSkillLevelSum += skillLevel - startingLevel + 1
            endif
            i += 1
        endWhile

        int perkPointsDeserved = effectiveSkillLevelSum / levelInterval
        perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
        int perkPointsEarned = CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt()

        if perkPointsDeserved < perkPointsEarned
            excessPoints = perkPointsEarned - perkPointsDeserved
        endif


    elseif CPP_PlayerLevelMode_Enabled.GetValue()
        int playerLevel = Player.GetLevel()
        int perkPointsEarned = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()
        int perkPointsDeserved = (playerLevel - calculationBaseline) / levelInterval
        perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()

        if playerLevel < startingLevel
            return 0
        elseif perkPointsDeserved < perkPointsEarned
            excessPoints =  perkPointsEarned - perkPointsDeserved
        endif


    else
        while i < CPP_SkillNames.Length
            int skillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int

            if CPP_SkillsDisabled[i].GetValue() == 0 && skillLevel >= startingLevel
                int perkPointsDeserved = (skillLevel - calculationBaseline) / levelInterval
                int perkPointsEarned = CPP_PerkPointsEarned[i].GetValueInt()

                perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()

                if perkPointsDeserved < perkPointsEarned
                    excessPoints += perkPointsEarned - perkPointsDeserved
                endif
            endif
            i += 1
        endWhile
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
        if CPP_SkillsDisabled[i].GetValue() == 0
            int skillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int
            if skillLevel == maxLevel
                CPP_PerkPointsEarned[i].SetValue(0)
                legendaryCount += 1
            endif
        endif
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