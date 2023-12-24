################################################################################
# 
# DLC item handlers.
# 
################################################################################

#===============================================================================
# Health Mochi
#===============================================================================
ItemHandlers::UseOnPokemonMaximum.copy(:HPUP, :HEALTHMOCHI)
ItemHandlers::UseOnPokemon.copy(:HPUP, :HEALTHMOCHI)

#===============================================================================
# Muscle Mochi
#===============================================================================
ItemHandlers::UseOnPokemonMaximum.copy(:PROTEIN, :MUSCLEMOCHI)
ItemHandlers::UseOnPokemon.copy(:PROTEIN, :MUSCLEMOCHI)

#===============================================================================
# Resist Mochi
#===============================================================================
ItemHandlers::UseOnPokemonMaximum.copy(:IRON, :RESISTMOCHI)
ItemHandlers::UseOnPokemon.copy(:IRON, :RESISTMOCHI)

#===============================================================================
# Genius Mochi
#===============================================================================
ItemHandlers::UseOnPokemonMaximum.copy(:CALCIUM, :GENIUSMOCHI)
ItemHandlers::UseOnPokemon.copy(:CALCIUM, :GENIUSMOCHI)

#===============================================================================
# Clever Mochi
#===============================================================================
ItemHandlers::UseOnPokemonMaximum.copy(:ZINC, :CLEVERMOCHI)
ItemHandlers::UseOnPokemon.copy(:ZINC, :CLEVERMOCHI)

#===============================================================================
# Swift Mochi
#===============================================================================
ItemHandlers::UseOnPokemonMaximum.copy(:CARBOS, :SWIFTMOCHI)
ItemHandlers::UseOnPokemon.copy(:CARBOS, :SWIFTMOCHI)

#===============================================================================
# Fresh-Start Mochi
#===============================================================================
ItemHandlers::UseOnPokemon.add(:FRESHSTARTMOCHI, proc { |item, qty, pkmn, scene|
  next false if pkmn.ev.values.none? { |ev| ev > 0 }
  GameData::Stat.each_main { |s| pkmn.ev[s.id] = 0 }
  pkmn.changeHappiness("vitamin")
  pkmn.calc_stats
  pbSEPlay("Use item in party")
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s base points were all reset to zero!", pkmn.name))
  next true
})

#===============================================================================
# Fairy Feather
#===============================================================================
Battle::ItemEffects::DamageCalcFromUser.copy(:PIXIEPLATE, :FAIRYFEATHER)

#===============================================================================
# Wellspring Mask, Hearthflame Mask, Cornerstone Mask
#===============================================================================
Battle::ItemEffects::DamageCalcFromUser.add(:WELLSPRINGMASK,
  proc { |item, user, target, move, mults, power, type|
    mults[:final_damage_multiplier] *= 1.2 if user.isSpecies?(:OGERPON)
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:WELLSPRINGMASK, :HEARTHFLAMEMASK, :CORNERSTONEMASK)