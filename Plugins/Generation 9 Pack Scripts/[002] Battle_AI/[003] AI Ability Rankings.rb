#===============================================================================
# AI Ability ranking handlers.
#===============================================================================
Battle::AI::Handlers::AbilityRanking.add(:ROCKYPAYLOAD,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:ROCK)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SHARPNESS,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.slicingMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SUPREMEOVERLORD,
  proc { |ability, score, battler, ai|
    next battler.effects[PBEffects::SupremeOverlord]
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ANGERSHELL,
  proc { |ability, score, battler, ai|
    next score if battler.hp > battler.totalhp/2
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:CUDCHEW,
  proc { |ability, score, battler, ai|
    next score if battler.item && battler.item.is_berry?
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ORICHALCUMPULSE,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.physicalMove? && [:Sun, :HarshSun].include?(battler.battler.effectiveWeather) }
    next score - 1
  }
)

Battle::AI::Handlers::AbilityRanking.add(:HADRONENGINE,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.specialMove? && battler.battler.battle.field.terrain == :Electric }
    next score - 1
  }
)