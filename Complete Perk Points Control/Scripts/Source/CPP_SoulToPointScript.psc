Scriptname CPP_SoulToPointScript extends ActiveMagicEffect  

GlobalVariable Property CPP_Spell_SoulToPoint_SoulsNeeded auto
GlobalVariable Property CPP_Spell_SoulToPoint_Points auto

Message Property CPP_MessageBox_SoulToPoint auto
Explosion Property ExplosionShoutArea01 Auto
ImageSpaceModifier Property MAGShoutPush01Imod Auto
EffectShader Property MS04MemoryFXShaderNew Auto
EffectShader Property FireCloakFXShader Auto
VisualEffect Property FXDragonDeathRHandBitsEffect Auto
VisualEffect Property MS04MemoryFXBody01VFX Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Actor Player = Game.GetPlayer()
    int soulsCollected = Player.GetActorValue("DragonSouls") as int
    int soulsNeeded = CPP_Spell_SoulToPoint_SoulsNeeded.GetValueInt()
    int perkPointsGain = CPP_Spell_SoulToPoint_Points.GetValueInt()

    MS04MemoryFXBody01VFX.Play(akTarget, 6)
    Utility.Wait(1)

    int buttonIndex = CPP_MessageBox_SoulToPoint.Show(soulsNeeded, perkPointsGain)

    if buttonIndex == 0 && soulsCollected >= soulsNeeded
        MAGShoutPush01Imod.Apply()
        MS04MemoryFXShaderNew.Play(akTarget, 2.0)
        FireCloakFXShader.Play(akTarget, 5)
        FXDragonDeathRHandBitsEffect.Play(akTarget, 5)
        ObjectReference fx = Game.GetPlayer().PlaceAtMe(ExplosionShoutArea01)

        Player.ModActorValue("DragonSouls", -soulsNeeded)
        Game.AddPerkPoints(perkPointsGain)

        if perkPointsGain > 1
            Debug.Notification("You've gained " + perkPointsGain + " perk points!")
        else
            Debug.Notification("You've gained a perk point!")
        endif

    elseif buttonIndex == 0 && soulsCollected < soulsNeeded
        Debug.Notification("You don't have enough souls.")
        MS04MemoryFXBody01VFX.Stop(akTarget)
        
    else
        MS04MemoryFXBody01VFX.Stop(akTarget)
    endif
EndEvent