Scriptname CPP_SkillTrackerScript extends Quest  

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

Int Property LEGENDARY_BASE_LEVEL = 15 AutoReadOnly

Event OnStoryIncreaseSkill(string asSkill)

    if CPP_ModEnabled.GetValueInt() == 0
        return
    endif

    if CPP_PlayerLevelMode_Enabled.GetValueInt() != 0
        return
    endif

    int skillIndex = CPP_SkillNames.Find(asSkill)
    if skillIndex < 0
        return
    endif

    if CPP_SkillsDisabled[skillIndex].GetValueInt() == 1
        return
    endif

    if CPP_LegendarySkillsEnabled.GetValueInt() == 0 && CPP_SkillLegendaryCount[skillIndex].GetValueInt() > 0
        return
    endif

    Actor playerRef = Game.GetPlayer()

    int skillLevel     = playerRef.GetBaseActorValue(asSkill) as int
    int startingLevel  = CPP_StartingLevel.GetValueInt()
    int levelInterval  = CPP_LevelInterval.GetValueInt()
    int maxLevel       = CPP_MaxSkillLevel.GetValueInt()
    int multiplier     = CPP_PerkPointsMultiplier.GetValueInt()

    if CPP_GlobalSkillMode_Enabled.GetValueInt() == 1 && skillLevel >= startingLevel
        HandleGlobalSkillMode(skillIndex, skillLevel, maxLevel, levelInterval, multiplier)
    else
        HandleNormalSkillMode(skillIndex, skillLevel, startingLevel, levelInterval, maxLevel, multiplier)
    endif
    
    Stop()
EndEvent

Function HandleGlobalSkillMode(int skillIndex, int skillLevel, int maxLevel, int levelInterval, int multiplier)

    int previousLevel = CPP_LastSkillLevel[skillIndex].GetValueInt()
    int gained        = skillLevel - previousLevel

    if gained < 0

        ; LEGENDARY RESET
        if previousLevel >= maxLevel && skillLevel <= LEGENDARY_BASE_LEVEL
            CPP_SkillLegendaryCount[skillIndex].SetValueInt(CPP_SkillLegendaryCount[skillIndex].GetValueInt() + 1)
        endif

        CPP_LastSkillLevel[skillIndex].SetValueInt(skillLevel)
        return
    endif

    if gained > 0
        CPP_GlobalSkillMode_LevelProgress.SetValueInt(CPP_GlobalSkillMode_LevelProgress.GetValueInt() + gained)
    endif

    int globalProgress = CPP_GlobalSkillMode_LevelProgress.GetValueInt()
    int deserved       = (globalProgress / levelInterval) * multiplier
    int given          = CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt()

    if deserved > given
        GivePerkPoints(deserved - given)
        CPP_GlobalSkillMode_PerkPointsEarned.SetValueInt(deserved)
    endif

    CPP_LastSkillLevel[skillIndex].SetValueInt(skillLevel)

EndFunction

Function HandleNormalSkillMode(int skillIndex, int skillLevel, int startingLevel, int levelInterval, int maxLevel, int multiplier)

    int previousLevel = CPP_LastSkillLevel[skillIndex].GetValueInt()

    if skillLevel < previousLevel

        if previousLevel >= maxLevel && skillLevel <= LEGENDARY_BASE_LEVEL
            CPP_SkillLegendaryCount[skillIndex].SetValueInt(CPP_SkillLegendaryCount[skillIndex].GetValueInt() + 1)
            CPP_PerkPointsEarned[skillIndex].SetValueInt(0)
        endif

        CPP_LastSkillLevel[skillIndex].SetValueInt(skillLevel)
        return
    endif

    int baseline = startingLevel - levelInterval
    int deserved = ((skillLevel - baseline) / levelInterval) * multiplier
    int current  = CPP_PerkPointsEarned[skillIndex].GetValueInt()

    if deserved <= current || deserved <= 0
        CPP_LastSkillLevel[skillIndex].SetValueInt(skillLevel)
        return
    endif

    int diff = deserved - current

    if skillLevel >= maxLevel
        CPP_PerkPointsEarned[skillIndex].SetValueInt(0)
    else
        CPP_PerkPointsEarned[skillIndex].SetValueInt(deserved)
    endif

    GivePerkPoints(diff)

    CPP_LastSkillLevel[skillIndex].SetValueInt(skillLevel)

EndFunction

Function GivePerkPoints(int amount)

    if amount <= 0
        return
    endif

    Game.AddPerkPoints(amount)

    if CPP_ShowNotifications.GetValueInt() != 0
        if amount > 1
            Debug.Notification("You've gained " + amount + " perk points!")
        else
            Debug.Notification("You've gained a perk point!")
        endif
    endif

EndFunction