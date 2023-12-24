################################################################################
# 
# DLC move handlers.
# 
################################################################################


#===============================================================================
# Matcha Gatcha
#===============================================================================
# User gains half the HP it inflicts as damage. It may also burn the target.
#-------------------------------------------------------------------------------
class Battle::Move::HealUserByHalfOfDamageDoneBurnTarget < Battle::Move::BurnTarget
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
    super
  end
end

#===============================================================================
# Syrup Bomb
#===============================================================================
# Lower Target Speed for 3 turns.
#-------------------------------------------------------------------------------
class Battle::Move::LowerTargetSpeedOverTime < Battle::Move
  def pbEffectWhenDealingDamage(user, target)
    if target.effects[PBEffects::Syrupy] <= 0
      target.effects[PBEffects::Syrupy] = 3
      @battle.pbDisplay(_INTL("{1} got covered in sticky candy syrup!", target.pbThis))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = (user.shiny?) ? 1 : 0
    super
  end
end

#===============================================================================
# Ivy Cudgel
#===============================================================================
# The type of the move changes to reflect Ogerpon's mask.
#-------------------------------------------------------------------------------
class Battle::Move::TypeIsUserSecondType < Battle::Move
  def pbBaseType(user)
    return @type if !user.isSpecies?(:OGERPON)
    userTypes = user.pokemon.types
    return userTypes[1] || userTypes[0] || @type
  end
  
  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    case pbBaseType(user)
	when :WATER then hitNum = 1
	when :FIRE  then hitNum = 2
	when :ROCK  then hitNum = 3
	else             hitNum = 0
	end
    super
  end
end