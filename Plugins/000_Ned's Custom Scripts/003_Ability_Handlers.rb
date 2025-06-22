

Battle::AbilityEffects::MoveImmunity.add(:THORNYWILDS,
  proc { |ability, user, target, move, type, battle, show_message|
    targetStats = target.plainStats
    highestStatValue = 0
    highestStat = :SPEED
    targetStats.each do |stat, value|
      next if value < highestStatValue
      highestStatValue = value
      highestStat = stat
    end
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
      :GRASS, highestStat, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:FIERYMAGIC,
  proc { |ability, user, target, move, type, battle, show_message|
    targetStats = target.plainStats
    highestStatValue = 0
    highestStat = :SPEED
    targetStats.each do |stat, value|
      next if value < highestStatValue
      highestStatValue = value
      highestStat = stat
    end
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
      :FIRE, highestStat, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:ROUGHWAVES,
  proc { |ability, user, target, move, type, battle, show_message|
    targetStats = target.plainStats
    highestStatValue = 0
    highestStat = :SPEED
    targetStats.each do |stat, value|
      next if value < highestStatValue
      highestStatValue = value
      highestStat = stat
    end
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
      :WATER, highestStat, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:FLAMEGUARD,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
      :FIRE, :ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ROOMOFDOOM,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    if battle.field.effects[PBEffects::TrickRoom] > 0
      battle.field.effects[PBEffects::TrickRoom] = 0
      battle.pbDisplay(_INTL("{1} reverted the dimensions!", battler.pbThis))
    else
      battle.field.effects[PBEffects::TrickRoom] = 5
      battle.field.effects[PBEffects::TrickRoom] = 8 if battler.hasActiveItem?(:ROOMSERVICE)
      battle.pbDisplay(_INTL("{1} twisted the dimensions!", battler.pbThis))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SPIRITTRAIN,
  proc { |ability, battler, battle, switch_in|
    battle.allOtherSideBattlers(battler.index).each do |b|
      if b.pbHasType?(:GHOST)
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} is connecting with {2}", battler.pbThis, b.name))
        battler.pbRaiseStatStageByAbility(:ATTACK, 2, battler)
        battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 2, battler)
        battle.pbHideAbilitySplash(battler)
        break
      end
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ABSOLUTEZERO,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Hail, battler)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:ABSOLUTEZERO,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if [:Hail].include?(user.effectiveWeather)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:GETAWAY,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if (move.function_code == "SwitchOutUserDamagingMove" || move.function_code == "SwitchOutTargetDamagingMove")
      mults[:attack_multiplier] *= 2.0
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:PERMAFROST,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.25 if type == :ICE
  }
)

Battle::AbilityEffects::MoveImmunity.add(:PERMAFROST,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :FIRE, show_message)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:GRANITEBODY,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.25 if type == :ROCK
  }
)

Battle::AbilityEffects::MoveImmunity.add(:GRANITEBODY,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :WATER, show_message)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:REINFORCED,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.25 if type == :FIGHTING
  }
)

Battle::AbilityEffects::MoveImmunity.add(:REINFORCED,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :FIGHTING, show_message)
  }
)
