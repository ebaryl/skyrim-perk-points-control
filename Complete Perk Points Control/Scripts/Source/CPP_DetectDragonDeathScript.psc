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

    ; Allow dragon soul/stat to update
    Utility.Wait(0.5)
    CPP_DragonDeaths_Monitor.SetValue(Game.QueryStat("Dragon Souls Collected"))

    int soulsGathered = CPP_DragonDeaths_SoulsGathered.GetValueInt() + 1
    int soulsNeeded  = CPP_DragonDeaths_SoulsNeeded.GetValueInt()

    ; Save early in case multiple dragons die at once
    CPP_DragonDeaths_SoulsGathered.SetValue(soulsGathered)

    if soulsGathered < soulsNeeded
        return
    endif

    int pointsMultiplier = CPP_DragonDeaths_Points.GetValueInt()
    int completedSets    = soulsGathered / soulsNeeded
    int remainingSouls   = soulsGathered % soulsNeeded

    int slainDragons = completedSets * soulsNeeded
    int pointsToAdd  = completedSets * pointsMultiplier

    Game.AddPerkPoints(pointsToAdd)
    CPP_DragonDeaths_SoulsGathered.SetValue(remainingSouls)

    if CPP_ShowNotifications.GetValue()
        string dragonText
        string pointText

        if slainDragons == 1
            dragonText = "a dragon"
        else
            dragonText = slainDragons + " dragons"
        endif

        if pointsToAdd == 1
            pointText = "a perk point"
        else
            pointText = pointsToAdd + " perk points"
        endif

        Debug.Notification("You've slain " + dragonText + " and earned " + pointText + "!")
    endif

EndEvent
