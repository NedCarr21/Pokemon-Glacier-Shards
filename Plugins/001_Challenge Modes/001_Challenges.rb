#-------------------------------------------------------------------------------
# Reload challenge data upon save reload
#-------------------------------------------------------------------------------
class PokemonLoad_Scene
  alias __challenge__pbStartScene2 pbStartScene2 unless method_defined?(:__challenge__pbStartScene2)
  def pbStartScene2
    ret = __challenge__pbStartScene2
    ChallengeModes.toggle(true) if ChallengeModes.running?
    return ret
  end
end

alias __challenge__pbTrainerName pbTrainerName unless defined?(__challenge__pbTrainerName)
def pbTrainerName(*args)
  ret = __challenge__pbTrainerName(*args)
  ChallengeModes.reset
  $player.challenge_state = {}
  return ret
end
=begin
#-------------------------------------------------------------------------------
# Prevent item usage in trainer battles
#-------------------------------------------------------------------------------
class Battle::Scene
  alias __challenge__pbItemMenu pbItemMenu unless method_defined?(:__challenge__pbItemMenu)
  def pbItemMenu(*args)
    if ChallengeModes.on?(:NO_TRAINER_BATTLE_ITEMS) && @battle.opponent
      rule_name = _INTL(ChallengeModes::RULES[:NO_TRAINER_BATTLE_ITEMS][:name])
      pbSEStop
      pbSEPlay("GUI sel buzzer")
      pbDisplayPausedMessage(_INTL("The \"{1}\" rule prevents item usage in Trainer Battles!", rule_name))
      return [0, -1]
    end
    return __challenge__pbItemMenu(*args)
  end
end
=end
#-------------------------------------------------------------------------------
# Add Perma faint functionality to Pokemon
#-------------------------------------------------------------------------------
class Battle::Battler

  def perma_faint
    return false if !ChallengeModes.on?(:PERMAFAINT)
    return @perma_faint
  end

  def perma_faint=(value)
    self.hp = 0 if @perma_faint
    @perma_faint = value
  end

  alias __challenge__hp hp unless method_defined?(:__challenge__hp)
  def hp
    return self.perma_faint ? 0 : __challenge__hp
  end

  alias __challenge__fainted? fainted? unless method_defined?(:__challenge__fainted?)
  def fainted?
    return true if self.perma_faint
    return __challenge__fainted?
  end

  alias __challenge__hp_set hp= unless method_defined?(:__challenge__hp_set)
  def hp=(val)
    @perma_faint = true if ChallengeModes.on?(:PERMAFAINT) && val <= 0
    new_val = self.perma_faint ? 0 : val
    __challenge__hp_set(new_val)
  end
end

=begin
ItemHandlers::UseOnPokemon.add(:REVIVE, proc { |item, qty, pokemon, scene|
  if pokemon.hp > 0 # || pokemon.perma_faint
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.hp = (pokemon.totalhp / 2).floor
    pokemon.healStatus
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:MAXREVIVE, proc { |item, qty, pokemon, scene|
  if pokemon.hp > 0 # || pokemon.perma_faint
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.healHP
    pokemon.healStatus
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:REVIVALHERB, proc{ |item, qty, pokemon, scene|
  if pokemon.hp > 0 # || pokemon.perma_faint
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.healHP
    pokemon.healStatus
    pokemon.changeHappiness("revivalherb")
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    next true
  end
})

ItemHandlers::UseInField.add(:SACREDASH, proc { |item|
  if $player.pokemonCount == 0
    Kernel.pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  canrevive = false
  for i in $player.pokemonParty
    if i.fainted? && !i.perma_faint
      canrevive = true
      break
    end
  end
  if !canrevive
    Kernel.pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  revived = 0
  pbFadeOutIn(99999) {
     scene = PokemonParty_Scene.new
     screen = PokemonPartyScreen.new(scene, $player.party)
     screen.pbStartScene(_INTL("Using item..."), false)
     for i in 0...$player.party.length
       if $player.party[i].fainted?
         revived += 1
         $player.party[i].heal
         screen.pbRefreshSingle(i)
         screen.pbDisplay(_INTL("{1}'s HP was restored.", $player.party[i].name))
       end
     end
     if revived == 0
       screen.pbDisplay(_INTL("It won't have any effect."))
     end
     screen.pbEndScene
  }
  next (revived == 0) ? 0 : 3
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE, proc { |item, pokemon, battler, scene|
  if pokemon.hp > 0 || pokemon.perma_faint
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.hp = (pokemon.totalhp / 2).floor
    pokemon.healStatus
    for i in 0...$player.party.length
      if $player.party[i] == pokemon
        battler.pbInitialize(pokemon, i, false) if battler
        break
      end
    end
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    next true
  end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE, proc { |item, pokemon, battler, scene|
  if pokemon.hp > 0 || pokemon.perma_faint
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.healHP
    pokemon.healStatus
    for i in 0...$player.party.length
      if $player.party[i] == pokemon
        battler.pbInitialize(pokemon, i, false) if battler
        break
      end
    end
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    next true
  end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB, proc { |item, pokemon, battler, scene|
  if pokemon.hp > 0 || pokemon.perma_faint
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.healHP
    pokemon.healStatus
    for i in 0...$player.party.length
      if $player.party[i] == pokemon
        battler.pbInitialize(pokemon, i, false) if battler
        break
      end
    end
    pokemon.changeHappiness("revivalherb")
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pokemon.name))
    next true
  end
})
=end
#-------------------------------------------------------------------------------
# Add Game Over methods
#-------------------------------------------------------------------------------
module Kernel

  class << self
    alias __challenge__pbStartOver pbStartOver unless method_defined?(:__challenge__pbStartOver)
  end

  def self.pbStartOver(*args)
    return __challenge__pbStartOver(*args) if !ChallengeModes.on?(:PERMAFAINT)
    resume = false
    pbEachPokemon do |pkmn, _|
      next if pkmn.fainted? || pkmn.egg?
      resume = true
      break
    end
    if resume && !ChallengeModes.on?(:GAME_OVER_WHITEOUT)
      while pbAllFainted
        Kernel.pbMessage("\\c[8]\\w[]\\wm\\l[3]" +
          _INTL("All your Pokémon have fainted. But you still have Pokémon in your PC which you can continue the challenge with."))
        pbFadeOutIn(99999) {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
        }
      end
    else
      Kernel.pbMessage("\\c[8]\\w[]\\wm\\l[3]" +
        _INTL("All your Pokémon have fainted. You have lost the challenge! All challenge modifiers will now be turned off."))
      ChallengeModes.set_loss
    end
    return __challenge__pbStartOver(*args)
  end
end

#-------------------------------------------------------------------------------
# One-Capture per route rule with shiny and dups clause
#-------------------------------------------------------------------------------
class Battle::Scene
  #-----------------------------------------------------------------------------
  # Flag map for encounter after first wild mon fainted
  #-----------------------------------------------------------------------------
  alias __challenge__pbFaintBattler pbFaintBattler unless method_defined?(:__challenge__pbFaintBattler)
  def pbFaintBattler(*args)
    return __challenge__pbFaintBattler(*args) if !ChallengeModes.on? || ChallengeModes.had_first_encounter? || @first_fainted
    ChallengeModes.set_first_encounter(args[0]) if !@battle.opponent
    @first_fainted = true
    return __challenge__pbFaintBattler(*args)
  end

#-----------------------------------------------------------------------------
# Flag map for encounter after battle ends
#-----------------------------------------------------------------------------
  alias __challenge__pbEndBattle pbEndBattle unless method_defined?(:__challenge__pbEndBattle)
  def pbEndBattle(*args)
    ret = __challenge__pbEndBattle(*args)
    return ret if !ChallengeModes.on? || @battle.opponent || ChallengeModes.had_first_encounter?
    battler = nil
    [1, 3].each { |i| battler = @battle.battlers[i] if !battler && @battle.battlers[i].pokemon }
    ChallengeModes.set_first_encounter(battler) if battler
    return ret
  end
end

module Battle::CatchAndStoreMixin
#-----------------------------------------------------------------------------
# Main Catch blocker system + flag map for encounter after Pokemon caught
#-----------------------------------------------------------------------------
  alias __challenge__pbThrowPokeBall pbThrowPokeBall unless method_defined?(:__challenge__pbThrowPokeBall)
  def pbThrowPokeBall(*args)
    battler = opposes?(args[0]) ? @battlers[args[0]] : @battlers[args[0]].pbOppositeOpposing
    # Disable Pokeball throwing if already caught
    if ChallengeModes.had_first_encounter?(battler)
      rule_name = _INTL(ChallengeModes::RULES[:ONE_CAPTURE][:name])
      pbSEStop
      pbSEPlay("GUI sel buzzer")
      return pbDisplayPaused(_INTL("The \"{1}\" rule prevents you from catching a Pokémon on a map you already had an encounter on!", rule_name))
    end
    owned_b4 = ChallengeModes.captured_evo_line?(battler.pokemon.species)
    if owned_b4 && ChallengeModes.on?(:DUPS_CLAUSE) && ChallengeModes.on?(:ONE_CAPTURE)
      rule_name = _INTL(ChallengeModes::RULES[:DUPS_CLAUSE][:name])
      rule_name2 = _INTL(ChallengeModes::RULES[:ONE_CAPTURE][:name])
      pbSEStop
      pbSEPlay("GUI sel buzzer")
      return pbDisplayPaused(_INTL("The \"{1}\" and \"{2}\" rules prevents you from catching a duplicate Pokémon!", rule_name,rule_name2))
    end
    ret      = __challenge__pbThrowPokeBall(*args)
    # Flag for caught Pokemon for map
    ChallengeModes.set_first_encounter(battler, owned_b4) if [1, 4].include?(@decision)
    return ret
  end
end

=begin
#-------------------------------------------------------------------------------
# One-Capture per route rule for gift Pokemon
#-------------------------------------------------------------------------------
alias __challenge__pbAddPokemon pbAddPokemon unless defined?(__challenge__pbAddPokemon)
def pbAddPokemon(*args)
  return false if !args[0]
  pkmn = args[0]; level = args[1]
  pkmn = getID(PBSpecies, pkmn) if !pkmn.is_a?(Integer)
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $player) if !pkmn.is_a?(PokeBattle_Pokemon)
  if ChallengeModes.had_first_encounter?(pkmn)
    rule_name = _INTL(ChallengeModes::RULES[:ONE_CAPTURE][:name])
    Kernel.pbMessage(_INTL("The \"{1}\" rule prevents you from obtaining a Pokémon on a map you already had an encounter on!", rule_name))
    return false
  end
  ret = __challenge__pbAddPokemon(*args)
  ChallengeModes.set_first_encounter(pkmn) if !ChallengeModes.on?(:GIFT_CLAUSE)
  return ret
end

alias __challenge__pbAddPokemonSilent pbAddPokemonSilent unless defined?(__challenge__pbAddPokemonSilent)
def pbAddPokemonSilent(*args)
  return false if !args[0]
  pkmn = args[0]; level = args[1]
  pkmn = getID(PBSpecies, pkmn) if !pkmn.is_a?(Integer)
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $player) if !pkmn.is_a?(PokeBattle_Pokemon)
  return false if ChallengeModes.had_first_encounter?(pkmn)
  ret = __challenge__pbAddPokemonSilent(*args)
  ChallengeModes.set_first_encounter(pkmn) if !ChallengeModes.on?(:GIFT_CLAUSE)
  return ret
end

alias __challenge__pbAddToParty pbAddToParty unless defined?(__challenge__pbAddToParty)
def pbAddToParty(*args)
  return false if !args[0]
  pkmn = args[0]; level = args[1]
  pkmn = getID(PBSpecies, pkmn) if !pkmn.is_a?(Integer)
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $player) if !pkmn.is_a?(PokeBattle_Pokemon)
  if ChallengeModes.had_first_encounter?(pkmn)
    rule_name = _INTL(ChallengeModes::RULES[:ONE_CAPTURE][:name])
    Kernel.pbMessage(_INTL("The \"{1}\" rule prevents you from obtaining a Pokémon on a map you already had an encounter on!", rule_name))
    return false
  end
  ret = __challenge__pbAddToParty(*args)
  ChallengeModes.set_first_encounter(pkmn) if !ChallengeModes.on?(:GIFT_CLAUSE)
  return ret
end

alias __challenge__pbAddToPartySilent pbAddToPartySilent unless defined?(__challenge__pbAddToPartySilent)
def pbAddToPartySilent(*args)
  return false if !args[0]
  pkmn = args[0]; level = args[1]
  pkmn = getID(PBSpecies, pkmn) if !pkmn.is_a?(Integer)
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $player) if !pkmn.is_a?(PokeBattle_Pokemon)
  return false if ChallengeModes.had_first_encounter?(pkmn)
  ret = __challenge__pbAddToPartySilent(*args)
  ChallengeModes.set_first_encounter(pkmn) if !ChallengeModes.on?(:GIFT_CLAUSE)
  return ret
end

alias __challenge__pbAddForeignPokemon pbAddForeignPokemon unless defined?(__challenge__pbAddForeignPokemon)
def pbAddForeignPokemon(*args)
  return false if !args[0]
  pkmn = args[0]; level = args[1]
  pkmn = getID(PBSpecies, pkmn) if !pkmn.is_a?(Integer)
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $player) if !pkmn.is_a?(PokeBattle_Pokemon)
  if ChallengeModes.had_first_encounter?(pkmn)
    rule_name = _INTL(ChallengeModes::RULES[:ONE_CAPTURE][:name])
    Kernel.pbMessage(_INTL("The \"{1}\" rule prevents you from obtaining a Pokémon on a map you already had an encounter on!", rule_name))
    return false
  end
  ret = __challenge__pbAddForeignPokemon(*args)
  ChallengeModes.set_first_encounter(pkmn) if !ChallengeModes.on?(:GIFT_CLAUSE)
  return ret
end

alias __challenge__pbGenerateEgg pbGenerateEgg unless defined?(__challenge__pbGenerateEgg)
def pbGenerateEgg(*args)
  return false if !args[0]
  pkmn = args[0]
  pkmn = getID(PBSpecies, pkmn) if !pkmn.is_a?(Integer)
  pkmn = PokeBattle_Pokemon.new(pkmn, EGGINITIALLEVEL, $player) if !pkmn.is_a?(PokeBattle_Pokemon)
  if ChallengeModes.had_first_encounter?(pkmn)
    rule_name = _INTL(ChallengeModes::RULES[:ONE_CAPTURE][:name])
    Kernel.pbMessage(_INTL("The \"{1}\" rule prevents you from obtaining a Pokémon on a map you already had an encounter on!", rule_name))
    return false
  end
  ret = __challenge__pbGenerateEgg(*args)
  ChallengeModes.set_first_encounter(pkmn) if !ChallengeModes.on?(:GIFT_CLAUSE)
  return ret
end


#-------------------------------------------------------------------------------
# No online participation for specific rules in Challenge Mode
#-------------------------------------------------------------------------------
alias __challenge__pbCableClub pbCableClub unless defined?(__challenge__pbCableClub)
def pbCableClub(*args)
  if ChallengeModes::ONLINE_BLOCK_RULES.any? { |r| ChallengeModes.on?(r) }
    Kernel.pbMessage(_INTL("I'm sorry, you cannot enter the Cable Club while in a Challenge."))
    return
  end
  return __challenge__pbCableClub(*args)
end

alias __challenge__pbReceiveMysteryGift pbReceiveMysteryGift unless defined?(__challenge__pbReceiveMysteryGift)
def pbReceiveMysteryGift(*args)
  $one_capture_override = true
  ret = __challenge__pbReceiveMysteryGift(*args)
  $one_capture_override = false
  return ret
end

alias __challenge__pbDebugMenu pbDebugMenu unless defined?(__challenge__pbDebugMenu)
def pbDebugMenu(*args)
  $one_capture_override = true
  ret = __challenge__pbDebugMenu(*args)
  $one_capture_override = false
  return ret
end
=end
