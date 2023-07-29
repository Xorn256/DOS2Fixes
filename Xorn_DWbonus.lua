--- @param weapon CDivinityStatsItem
--- @param character CDivinityStatsCharacter
--- @param criticalMultiplier number
--- @return number
local function GetCriticalHitMultiplier(weapon, character, criticalMultiplier)
    criticalMultiplier = criticalMultiplier or 0
    if weapon.ItemType == "Weapon" then
        for i,stat in pairs(weapon.DynamicStats) do
            criticalMultiplier = criticalMultiplier + stat.CriticalDamage
        end
  
        if character ~= nil then
            local ability = Game.Math.GetWeaponAbility(character, weapon)
            criticalMultiplier = criticalMultiplier + Game.Math.GetAbilityCriticalHitMultiplier(character, ability) + Game.Math.GetAbilityCriticalHitMultiplier(character, "RogueLore")
                
            if character.TALENT_Human_Inventive then
                criticalMultiplier = criticalMultiplier + Ext.ExtraData.TalentHumanCriticalMultiplier
            end

            if character.DualWielding > 0 then
              local mult = Ext.ExtraData.MyMod_DualWieldingCriticalBoostPerPoint or 0.2
              criticalMultiplier = criticalMultiplier * (character.DualWielding * mult)
            end
        end
    end
  
    return criticalMultiplier * 0.01
end

if Ext.IsServer() then
Ext.Events.ComputeCharacterHit:Subscribe(function (e)
    if not e.Handled and e.Attacker and e.Attacker.DualWielding > 0 then
        local hit = Game.Math.ComputeCharacterHit(e.Target, e.Attacker, e.Weapon, e.DamageList, e.HitType, e.NoHitRoll, e.ForceReduceDurability, e.Hit, e.AlwaysBackstab, e.HighGround, e.CriticalRoll)
        if hit then
            e.Handled = true
        end
    end
end, {Priority=0})
end