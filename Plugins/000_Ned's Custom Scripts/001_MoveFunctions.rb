
class Battle::Move::DoublePowerIfTargetDarkType < Battle::Move # Shadow Seeker
  def pbBaseDamage(baseDmg, user, target)
    if (target.pbHasType?(:DARK)) &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
       baseDmg *= 2
    end
    return baseDmg
  end
end

class Battle::Move::DoubleDamageInHail < Battle::Move # Hail Blade
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *=2 if [:Hail].include?(user.effectiveWeather)
    return baseDmg
  end
end

class Battle::Move::DamageBasedOnTargetAtkAndSpAtk < Battle::Move # Energy Burst
  def pbBaseDamage(baseDmg, user, target)
    str = (target.baseStats[:ATTACK] + target.baseStats[:SPECIAL_ATTACK])
    return (str/2).floor
  end
end

class Battle::Move::DamageIfGhostAlly < Battle::Move # Chain of Spirits
  def pbBaseDamage(baseDmg, user, target)
    user.allAllies.each do |b|
      if (b.pbHasType?(:GHOST))
        baseDmg *= 2
        pbMessage(_INTL("{1}\'s Chain of Spirits was empowered by {2}", user.name, b.name))
      end
    end
    return baseDmg
  end
end

class Battle::Move::FixedDamage100 < Battle::Move::FixedDamageMove # Sonic Edge
  def pbFixedDamage(user, target)
    return 100
  end
end

class Battle::Move::AttackRevealHeldItem < Battle::Move # Aqua Report
  def pbEffectAfterAllHits(user, target)
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item
    return if target.unlosableItem?(target.item)
    return if !@battle.moldBreaker
    itemName = target.itemName
    # Permanently steal the item from wild Pokémon
    @battle.pbDisplay(_INTL("{1} reported on {2} and found its {3}!", user.pbThis, target.pbThis(true), itemName))
  end
end
