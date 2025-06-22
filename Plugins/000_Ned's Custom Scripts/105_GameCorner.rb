#
#
#
#
#
#
#
TYPE_REWARDS = {
  :NORMAL => [],
  :FIGHTING => []

}

# rewards based on stat num => [0-70, 71-140, 141-210, 211-280, 281-350, 351-420, 421-490, 491+]
STAT_REWARDS = {
  :HP => [:ORANBERRY, :SITRUSBERRY, ]



}
def rand_quality_from_choose()

  pbChoosePokemon(1, 3) # party slot staored in $game_variables[1] & pkmn stored in var 3.
  pkmn = pbGetPokemon(1)
  type = pkmn.types.sample
  stat = [
    pkmn.totalhp,
    pkmn.attack,
    pkmn.defense,
    pkmn.spatk,
    pkmn.spdef,
    pkmn.speed
  ].sample

  if (rand(1) == 0) # based on pkmns typing
    TYPE_REWARDS[stat].random

  else # based on pkmns stats

  end

end


OVERRIDE = {
  :CLAMPERL => [:DEEPSEASCALE, :DEEPSEATOOTH],
  :FARFETCHD => [:LEEK],
  :SIRFETCHD => [:LEEK],
  :PIKACHU => [:LIGHTBALL],
  :CHANSEY => [:LUCKYPUNCH, :LUCKYEGG],
  :DITTO => [:QUICKPOWDER, :SILVERPOWDER],
  :LATIAS => [:SOULDEW],
  :LATIOS => [:SOULDEW],
  :CUBONE => [:THICKCLUB],
  :MAROWAK => [:THICKCLUB],

  :FLAPPLE => [:TARTAPPLE],
  :APPLETUN => [:SWEETAPPLE],
  :DIPPLIN => [:SYRYPYAPPLE],
  :ARMAROUGE => [:AUSPICIOUSARMOR],
  :CERULEDGE => [:MALICIOUSARMOR],
  :ARCHALUDON => [:METALALLOY],
  :SINISTCHA => [:MASTERPIECETEACUP, :UNREMARKABLETEACUP],
  :KLEAVOR => [:BLACKAUGURITE],
  :POLTEAGEIST => [:CHIPPEDPOT, :CRACKEDPOT],
  :SLOWKING => [:GALARICAWREATH, :KINGSROCK],
  :URSALUNA => [:PEATBLOCK],
  :GOREBYSS => [:DEEPSEASCALE],
  :HUNTAIL => [:DEEPSEATOOTH],
  :KINGDRA => [:DRAGONSCALE],
  :PORYGONZ => [:DUBIOUSDISC],
  :PORYGON2 => [:UPGRADE],
  :ELECTIVIRE => [:ELECTIRIZER],
  :MAGMORTAR => [:MAGMARIZER]

}

def check_override_item(pkmn)
  # manual form checks
    # if pkmn evolved using an item, return item, otherwise return -1.




end
