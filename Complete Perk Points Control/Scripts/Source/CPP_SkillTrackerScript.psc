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
GlobalVariable Property CPP_PlayerLevelMode_Enabled auto
GlobalVariable Property CPP_PlayerLevelMode_PerkPointsEarned auto
GlobalVariable Property CPP_PerkPointsMultiplier auto

Event OnStoryIncreaseSkill(string asSkill)
    if CPP_ModEnabled.GetValue() && CPP_PlayerLevelMode_Enabled.GetValue() == 0
        int skill_index = CPP_SkillNames.Find(asSkill)
        ; skill_index = ktory skill dostal level
        if skill_index < 0 || CPP_SkillsDisabled[skill_index].GetValue() == 1
            Stop()
        endif

        Actor Player = Game.GetPlayer()

        int skillLevel = Player.GetBaseActorValue(asSkill) as int
        int startingLevel = CPP_StartingLevel.GetValueInt()
        int levelInterval = CPP_LevelInterval.GetValueInt()
        int maxLevel = CPP_MaxSkillLevel.GetValueInt()

        if CPP_GlobalSkillMode_Enabled.GetValue() == 1 && skillLevel >= startingLevel
            
            int i = 0
            int globalLevelCount = 0
            ;int normalModeCount = 0
            ;int PlayerLevelModeCount = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()

            while i < CPP_SkillNames.Length
                if (!CPP_SkillsDisabled[i].GetValue()) 
                    int currentSkillLevel = Player.GetBaseActorValue(CPP_SkillNames[i]) as int
                    if currentSkillLevel >= startingLevel
                        globalLevelCount += currentSkillLevel - startingLevel + 1; globalLevel += skillLevel
                        ;normalModeCount += CPP_PerkPointsEarned[i].GetValueInt()
                    endif
                endIf
                i += 1
            endwhile
            ;Debug.Notification("globalLevelCount = " + globalLevelCount)
            ;int perkPointsDeserved = (globalLevelCount + normalModeCount + PlayerLevelModeCount) / levelInterval
            int perkPointsDeserved = globalLevelCount / levelInterval
            ;Debug.Notification("perkPointsDeserved = " + perkPointsDeserved)
            perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
            int perkPointsGiven = CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt()

            if perkPointsDeserved > perkPointsGiven
                int diff = perkPointsDeserved - perkPointsGiven
            
                Game.AddPerkPoints(diff)

                CPP_GlobalSkillMode_PerkPointsEarned.SetValueInt(perkPointsDeserved)

                PerkNotifications(CPP_ShowNotifications.GetValueInt(), diff)
            endif


        else
       
            int calculationBaseline = startingLevel - levelInterval
            int currentPerkBalance = CPP_PerkPointsEarned[skill_index].GetValueInt()

            int perkPointsDeserved = (skillLevel - calculationBaseline) / levelInterval
            perkPointsDeserved = perkPointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
        
            if perkPointsDeserved > 0 && perkPointsDeserved > currentPerkBalance
                int diff = perkPointsDeserved - currentPerkBalance
                ; CPP_PerkPointsEarned[skill_index].SetValue(perkPointsDeserved)

                if skillLevel == maxLevel
                    CPP_PerkPointsEarned[skill_index].SetValue(0)
                else
                    CPP_PerkPointsEarned[skill_index].SetValue(perkPointsDeserved)
                endif
            
                Game.AddPerkPoints(diff)
                PerkNotifications(CPP_ShowNotifications.GetValueInt(), diff)
            endif
        endif
    endif

    Stop()
EndEvent

Function PerkNotifications(int enabled,int value)
    if enabled
        if value > 1
            Debug.Notification("You've gained " + value + " perk points!")
        else
            Debug.Notification("You've gained a perk point!")
        endIf
    endif
EndFunction

        ; if CPP_GlobalSkillMode_Enabled.GetValueInt() && skillLevel >= CPP_StartingLevel.GetValueInt()
        ;     ;osobne liczenie
        ;     ;jesli level jest ok

        ;     int levelCount = CPP_GlobalSkillMode_LevelCount.GetValueInt() + 1
        ;     ;CPP_GlobalSkillMode_LevelCount.SetValueInt(levelCount)
        ;     ;ile leveli gracz zdobyl ogolnie

        ;     ;sprawdzic co ile leveli jest perk point

        ;     int perkPointsDeserved = levelCount / CPP_LevelInterval.GetValueInt()
        ;     if perkPointsDeserved >= 1
        ;         Game.AddPerkPoints(perkPointsDeserved)

        ;         CPP_GlobalSkillMode_LevelCount.SetValueInt()

        ;         CPP_GlobalSkillMode_PerkPointsEarned.SetValueInt(CPP_GlobalSkillMode_PerkPointsEarned.GetValueInt() + 1)
        ;     endif