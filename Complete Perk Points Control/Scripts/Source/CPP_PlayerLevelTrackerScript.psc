Scriptname CPP_PlayerLevelTrackerScript extends Quest

GlobalVariable Property CPP_ModEnabled auto
GlobalVariable Property CPP_PlayerLevelMode_Enabled auto
GlobalVariable Property CPP_PlayerLevelMode_PerkPointsEarned auto
GlobalVariable Property CPP_PerkPointsMultiplier Auto
GlobalVariable Property CPP_StartingLevel auto
GlobalVariable Property CPP_LevelInterval auto
GlobalVariable Property CPP_MaxSkillLevel auto
GlobalVariable Property CPP_ShowNotifications auto


Event OnStoryIncreaseLevel(int aiNewLevel)
    int playerLevel = Game.GetPlayer().GetLevel() ; aiNewLevel is not accurate
    int startingLevel = CPP_StartingLevel.GetValueInt()
    int levelInterval = CPP_LevelInterval.GetValueInt()

    if CPP_ModEnabled.GetValue() && CPP_PlayerLevelMode_Enabled.GetValue() && playerLevel >= startingLevel

        int calculationBaseline = startingLevel - levelInterval
        int pointsDeserved = (playerLevel - calculationBaseline) / levelInterval
        pointsDeserved = pointsDeserved * CPP_PerkPointsMultiplier.GetValueInt()
        int pointsEarned = CPP_PlayerLevelMode_PerkPointsEarned.GetValueInt()

        if pointsEarned < pointsDeserved
            int pointsToAdd = pointsDeserved - pointsEarned

            CPP_PlayerLevelMode_PerkPointsEarned.SetValue(pointsDeserved)
            Game.AddPerkPoints(pointsToAdd)

            if CPP_ShowNotifications.GetValue()
                if pointsToAdd > 1
                    Debug.Notification("You've gained " + pointsToAdd + " perk points!")
                else
                    Debug.Notification("You've gained a perk point!")
                endIf
            endif
        endif
    endif
    Stop()
EndEvent