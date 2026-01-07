Scriptname CPP_DetectDragonDeathScript extends ActiveMagicEffect

GlobalVariable Property CPP_ModEnabled auto
GlobalVariable Property CPP_DragonDeaths_Enabled auto
GlobalVariable Property CPP_DragonDeaths_Monitor auto
GlobalVariable Property CPP_DragonDeaths_SoulsNeeded auto
GlobalVariable Property CPP_DragonDeaths_SoulsGathered auto
GlobalVariable Property CPP_DragonDeaths_Points auto
GlobalVariable Property CPP_ShowNotifications auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    if CPP_ModEnabled.GetValue() == 0 || CPP_DragonDeaths_Enabled.GetValue() == 0
        return
    endif
    
    Utility.Wait(0.5)
    CPP_DragonDeaths_Monitor.SetValue(Game.QueryStat("Dragon Souls Collected"))

    int soulsGathered = CPP_DragonDeaths_SoulsGathered.GetValueInt() + 1
    int soulsNeeded = CPP_DragonDeaths_SoulsNeeded.GetValueInt()
    CPP_DragonDeaths_SoulsGathered.SetValue(soulsGathered) ; assurance if multiple dragons

    if soulsGathered < soulsNeeded
        return
    endif

    int pointsMultiplier = CPP_DragonDeaths_Points.GetValueInt()

    ; int pointsToAdd = soulsGathered / soulsNeeded
    ; int remaining = soulsGathered - (pointsToAdd * soulsNeeded)
    ; pointsToAdd = pointsToAdd * pointsMultiplier

    int completedSets = soulsGathered / soulsNeeded
    int remainingSouls = soulsGathered % soulsNeeded
    int pointsToAdd = completedSets * pointsMultiplier
    int slainDragons = completedSets * soulsNeeded

    Game.AddPerkPoints(pointsToAdd)
    CPP_DragonDeaths_SoulsGathered.SetValue(remainingSouls)
    
    if CPP_ShowNotifications.GetValue()
        if slainDragons == 1 && pointsToAdd == 1
            Debug.Notification("You've slain a dragon and earned a perk point!")
        elseif slainDragons == 1 && pointsToAdd > 1
            Debug.Notification("You've slain a dragon and earned " + pointsToAdd + " perk points!")
        elseif slainDragons > 1 && pointsToAdd == 1
            Debug.Notification("You've slain " + slainDragons + " dragons and earned a perk point!")
        else
            Debug.Notification("You've slain " + slainDragons + " dragons and earned " + pointsToAdd + " perk points!")
        endif
    endif
EndEvent