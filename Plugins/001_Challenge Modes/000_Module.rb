module ChallengeModes

  # Any selected challenge modifiers will only apply after getting
  # a Pokeball Item
  BEGIN_CHALLENGE_AFTER_GETTING_POKEBALL = false

  # Array of species that are to be ignored when checking for "One
  # Capture per Map" rule
  ONE_CAPTURE_WHITELIST = [
    :DIALGA, :PALKIA, :GIRATINA
  ]

  # Rules that prevent you from accessing online functionality
  ONLINE_BLOCK_RULES = [
    :PERMAFAINT, :ONE_CAPTURE
  ]

  # Groups of Map IDs that should be considered as one map in the case
  # where one large map is split up into multiple small maps
  SPLIT_MAPS_FOR_ENCOUNTERS = [
    [79,85], # Wooded Hill
    [92,93]  # Icy Plains
  ]

  # Name and Description for all the rules that can be toggled in the challenge
  RULES = {
    :PERMAFAINT => {
      :name  => _INTL("Permafaint"),
      :desc  => _INTL("Pokémon that are fainted cannot be revived. The challenge ends once all owned Pokémon faint."),
      :order => 1
    },
    :ONE_CAPTURE => {
      :name  => _INTL("One Capture per Map"),
      :desc  => _INTL("Only the first Pokémon encountered on a map can be caught and added to your party."),
      :order => 2
    },
    :SHINY_CLAUSE => {
      :name  => _INTL("Shiny Clause"),
      :desc  => _INTL("Shiny Pokémon are exempt from the \"One Capture per Map\" rule."),
      :order => 3
    },
    :DUPS_CLAUSE => {
      :name  => _INTL("Dupes Clause"),
      :desc  => _INTL("Evolution lines of owned species don't count as \"first encounters\" in the \"One Capture per Map\" rule."),
      :order => 4
    },
    :GIFT_CLAUSE => {
      :name  => _INTL("Gift Clause"),
      :desc  => _INTL("Gifted Pokémon and Eggs don't count as \"first encounters\" in the \"One Capture per Map\" rule."),
      :order => 5
    },
    :RANDOMIZER => {
      :name  => _INTL("Randomizer"),
      :desc  => _INTL("Pokémon obtained throughout the game will be randomized from the Regional Pokédex."),
      :order => 6
    },
    :NO_TRAINER_BATTLE_ITEMS => {
      :name  => _INTL("No Items in Trainer Battles"),
      :desc  => _INTL("Item usage will be disabled in Trainer Battles."),
      :order => 7
    }
  }

  # Name and Rules for all the pre defined challenge mode presets
  PRESETS = {
    :PARASOMNIA_MODE => {
      :name  => _INTL("Impossible"),
      :rules => [:PERMAFAINT, :ONE_CAPTURE, :NO_TRAINER_BATTLE_ITEMS, :SHINY_CLAUSE],
      :order => 1
    },
    :NUZLOCKE => {
      :name  => _INTL("Nuzlocke"),
      :rules => [:PERMAFAINT, :ONE_CAPTURE, :SHINY_CLAUSE, :DUPS_CLAUSE, :GIFT_CLAUSE],
      :order => 2
    },
    :RANDOMIZER_NUZLOCKE => {
      :name  => _INTL("Randomizer Nuzlocke"),
      :rules => [:PERMAFAINT, :ONE_CAPTURE, :SHINY_CLAUSE, :DUPS_CLAUSE, :GIFT_CLAUSE, :RANDOMIZER],
      :order => 2
    },
    :HARDCORE_NULOCKE => {
      :name  => _INTL("Hardcore Nuzlocke"),
      :rules => [:PERMAFAINT, :ONE_CAPTURE, :SHINY_CLAUSE, :DUPS_CLAUSE, :GIFT_CLAUSE, :NO_TRAINER_BATTLE_ITEMS],
      :order => 3
    }
  }
end

#-------------------------------------------------------------------------------
# Various data to be stored related to challenge modes
#-------------------------------------------------------------------------------
class Player < Trainer
  attr_accessor :challenge_qued
  attr_accessor :challenge_started
  attr_accessor :challenge_rules
  attr_accessor :challenge_encs

  attr_writer :challenge_state

  def challenge_state
    @challenge_state = {} if !@challenge_state.is_a?(Hash)
    return @challenge_state
  end
end

#-------------------------------------------------------------------------------
# Main Module for handling challenge data
#-------------------------------------------------------------------------------
module ChallengeModes
  @@started = false

  module_function
#-----------------------------------------------------------------------------
# check if challenge is on, toggle challenge state and get rules
#-----------------------------------------------------------------------------
  def running?; return $player && $player.challenge_started; end

  def on?(rule = nil)
    return false if !(running? && @@started)
    return rule.nil? ? true : rules.include?(rule)
  end

  def toggle(force = nil); @@started = force.nil? ? !@@started : force; end

  def rules; return ($player && $player.challenge_rules) || []; end
#-----------------------------------------------------------------------------
# Main command to start the challenge
#-----------------------------------------------------------------------------
  def start
    $player.challenge_rules = select_mode
    return if $player.challenge_rules.empty?
    $player.challenge_encs  = {}
    if BEGIN_CHALLENGE_AFTER_GETTING_POKEBALL
      $player.challenge_qued  = true
      return if !$PokemonBag
      for i in 1..PBItems.maxValue
        next if !pbIsPokeBall?(i) || !$PokemonBag.pbHasItem?(i)
        begin_challenge
        Kernel.pbMessage(_INTL("Your Challenge has begun! Good Luck!"))
        break
      end
    else
      $player.challenge_qued = false
      begin_challenge
      Kernel.pbMessage(_INTL("Your Challenge has begun! Good Luck!"))
    end
  end
#----------------------------------------------------------------------------
# Script command to begin challenge
#----------------------------------------------------------------------------
  def begin_challenge
    @@started                      = true
    $player.challenge_started      = true
    $player.challenge_qued         = false
  end
  #-----------------------------------------------------------------------------
  # Clear all challenge data and stop the challenge
  #-----------------------------------------------------------------------------
  def reset
    @@started                             = false
    return if !$player
    $player.challenge_qued               = nil
    $player.challenge_encs               = nil
    $player.challenge_started            = nil
    pbEachPokemon do |pkmn, _|
      next if !pkmn.respond_to?(:perma_faint)
      pkmn.perma_faint = false
    end
    # Intentionally not resetting rules so that they can be assessed later in case of loss
  end
  #-----------------------------------------------------------------------------
  # Commands to signify victory/loss in challenge
  #-----------------------------------------------------------------------------
  def set_victory(should_reset = false)
    return if !ChallengeModes.on?
    num = $PokemonGlobal.hallOfFameLastNumber
    num = 0 if num < 0
    $player.challenge_state[num] = [:VICTORY, ChallengeModes.rules.clone]
    reset if should_reset
  end

  def set_loss(should_reset = true)
    num = $PokemonGlobal.hallOfFameLastNumber
    num = 0 if num < 0
    return if !ChallengeModes.on? || ChallengeModes.won?(num)
    $player.challenge_state[num] = [:LOSS, ChallengeModes.rules.clone]
    reset if should_reset
  end

  def won?(hall_no = -1)
    if hall_no == -1
      return $player.challenge_state.values.any? { |v| v.is_a?(Array) && v[0] == :VICTORY }
    else
      return false if !$player.challenge_state[hall_no].is_a?(Array)
      return $player.challenge_state[hall_no][0] == :VICTORY
    end
  end

  def lost?(hall_no = -1)
    if hall_no == -1
      return $player.challenge_state.values.any? { |v| v.is_a?(Array) && v[0] == :LOSS }
    else
      return false if !$player.challenge_state[hall_no].is_a?(Array)
      return $player.challenge_state[hall_no][0] == :LOSS
    end
  end
  #-----------------------------------------------------------------------------
  #  recurring function to get every evolution after defined species
  #-----------------------------------------------------------------------------
  def get_other_evos(species)
    evo = GameData::Species.get(species).get_evolutions
    all = []
    return [species] if evo.length < 1
    evo.each do |arr|
      all += [arr[0]]
      all += get_other_evos(arr[0])
    end
    return all.uniq
  end
  #-----------------------------------------------------------------------------
  #  function to get all species inside an evolutionary line
  #-----------------------------------------------------------------------------
  def get_evo_line(species)
    species = GameData::Species.get(species).get_baby_species
    return ([species] + get_other_evos(species)).uniq
  end
  #-----------------------------------------------------------------------------
  #  checks if an evo line has been caught so far
  #-----------------------------------------------------------------------------
  def captured_evo_line?(species)
    return false if !$player || !$player.challenge_encs
    get_evo_line(species).each do |pkmn|
      return true if $player.pokedex.owned?(pkmn)
    end
    return false
  end
  #-----------------------------------------------------------------------------
  # Set and check for encounter on map
  #-----------------------------------------------------------------------------
  def set_first_encounter(pkmn, owned_flag = nil)
    return if !ChallengeModes.on?(:ONE_CAPTURE)
    return if $one_capture_override
    captured = true
    captured = false if ChallengeModes::ONE_CAPTURE_WHITELIST.any? { |s| isConst?(pkmn.species, PBSpecies, s) }
    if ChallengeModes.on?(:DUPS_CLAUSE)
      get_evo_line(pkmn.species).each do |pk|
        captured = false if owned_flag.nil? ? $player.pokedex.owned?(pkmn.species) : owned_flag
      end
    end
    captured = false if ChallengeModes.on?(:SHINY_CLAUSE) && pkmn.isShiny?
    return if !captured
    map_id = $game_map.map_id
    $player.challenge_encs[map_id] = true
    ChallengeModes::SPLIT_MAPS_FOR_ENCOUNTERS.each do |map_grp|
      next if !map_grp.include?(map_id)
      map_grp.each { |m| $player.challenge_encs[m] = true }
    end
  end

  def had_first_encounter?(pkmn = nil)
    return false if !ChallengeModes.on?(:ONE_CAPTURE)
    return false if pkmn && pkmn.isShiny? && ChallengeModes.on?(:SHINY_CLAUSE)
    return false if $one_capture_override
    map_id = $game_map.map_id
    return true if $player.challenge_encs[map_id]
    ChallengeModes::SPLIT_MAPS_FOR_ENCOUNTERS.each do |map_grp|
      next if !map_grp.include?(map_id)
      map_grp.each { |m| return true if $player.challenge_encs[m] }
    end
    return false
  end
  #-----------------------------------------------------------------------------
end
