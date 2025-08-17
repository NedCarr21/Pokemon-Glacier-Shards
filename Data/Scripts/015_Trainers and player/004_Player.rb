#===============================================================================
# Trainer class for the player
#===============================================================================
class Player < Trainer
  # @return [Integer] the character ID of the player
  attr_reader   :character_ID
  # @return [Integer] the player's outfit
  attr_reader   :outfit
  # @return [Array<Boolean>] the player's Gym Badges (true if owned)
  attr_accessor :badges
  # @return [Integer] the player's money
  attr_reader   :money
  # @return [Integer] the player's Game Corner coins
  attr_reader   :coins
  # @return [Integer] the player's battle points
  attr_reader   :battle_points
  # @return [Integer] the player's soot
  attr_reader   :soot
  # @return [Pokedex] the player's Pokédex
  attr_reader   :pokedex
  # @return [Boolean] whether the Pokédex has been obtained
  attr_accessor :has_pokedex
  # @return [Boolean] whether the Pokégear has been obtained
  attr_accessor :has_pokegear
  # @return [Boolean] whether the player has running shoes (i.e. can run)
  attr_accessor :has_running_shoes
  # @return [Boolean] whether the player has an innate ability to access Pokémon storage
  attr_accessor :has_box_link
  # @return [Boolean] whether the creator of the Pokémon Storage System has been seen
  attr_accessor :seen_storage_creator
  # @return [Boolean] whether the effect of Exp All applies innately
  attr_accessor :has_exp_all
  # @return [Boolean] whether Mystery Gift can be used from the load screen
  attr_accessor :mystery_gift_unlocked
  # @return [Array<Array>] downloaded Mystery Gift data
  attr_accessor :mystery_gifts

  attr_writer :minigames

  attr_writer :quest_data

  attr_writer :pokenav

  attr_writer :qb_quests

  attr_writer :guild_data

  def initialize(name, trainer_type)
    super
    @character_ID          = 0
    @outfit                = 0
    @badges                = [false] * 8
    @money                 = GameData::Metadata.get.start_money
    @coins                 = 0
    @battle_points         = 0
    @soot                  = 0
    @pokedex               = Pokedex.new
    @has_pokedex           = false
    @has_pokegear          = false
    @has_running_shoes     = false
    @has_box_link          = false
    @seen_storage_creator  = false
    @has_exp_all           = false
    @mystery_gift_unlocked = false
    @mystery_gifts         = []
    @minigames             = {}
    @quest_data            = {}
    @qb_quests             = []
    @guild_data            = {:tier => "none", :level => 1, :xp => 0}
    @pokenav               = {:pokedex => false, :townmap => false, :dexnav => false, :quests => false, :tutornet => false, :wondertrade => false}
  end

  #=============================================================================

  def pokenav_unlock(sym)
    message = "error..."
    case sym
    when :pokedex
      message = "The Pokédex App was loaded into the Poké Nav..."
    when :townmap
      message = "The Town Map App was loaded into the Poké Nav..."
    when :dexnav
      message = "The Dex Nav App was loaded into the Poké Nav..."
    when :quests
      message = "Your Adventure Log was loaded into the Poké Nav..."
    when :tutornet
      message = "The Move Tutor App was loaded into the Poké Nav..."
    when :wondertrade
      message = "The Wonder Trading System was loaded into the Poké Nav..."
    end
    pbMessage(_INTL(message))
    (0..2).each do
      pbSEPlay("Battle ball shake", 70, 140)
      pbWait(0.5)
    end
    @pokenav[sym] = true
  end

  def pokenav?
    return !$game_switches[91]
  end

  def pokenav
    return @pokenav
  end

  def qb_quests
    return @qb_quests
  end

  def reset_all_quests
    (0..2).each do |n|
      $player.qb_quests[n] = generateQuest
    end
  end

  def guild_data
    return @guild_data
  end

  def set_guild_data(sym, val)
    puts "Set Guild Data: #{sym} to #{val}"
    @guild_data[sym] = val
  end

  def minigames
    return @minigames
  end

  def character_ID=(value)
    return if @character_ID == value
    @character_ID = value
    $game_player&.refresh_charset
  end

  def outfit=(value)
    return if @outfit == value
    @outfit = value
    $game_player&.refresh_charset
  end

  def trainer_type
    return GameData::PlayerMetadata.get(@character_ID || 1).trainer_type
  end

  # Sets the player's money. It can not exceed {Settings::MAX_MONEY}.
  # @param value [Integer] new money value
  def money=(value)
    validate value => Integer
    @money = value.clamp(0, Settings::MAX_MONEY)
  end

  # Sets the player's coins amount. It can not exceed {Settings::MAX_COINS}.
  # @param value [Integer] new coins value
  def coins=(value)
    validate value => Integer
    @coins = value.clamp(0, Settings::MAX_COINS)
  end

  # Sets the player's Battle Points amount. It can not exceed
  # {Settings::MAX_BATTLE_POINTS}.
  # @param value [Integer] new Battle Points value
  def battle_points=(value)
    validate value => Integer
    @battle_points = value.clamp(0, Settings::MAX_BATTLE_POINTS)
  end

  # Sets the player's soot amount. It can not exceed {Settings::MAX_SOOT}.
  # @param value [Integer] new soot value
  def soot=(value)
    validate value => Integer
    @soot = value.clamp(0, Settings::MAX_SOOT)
  end

  # @return [Integer] the number of Gym Badges owned by the player
  def badge_count
    return @badges.count { |badge| badge == true }
  end

  #=============================================================================

  # (see Pokedex#seen?)
  # Shorthand for +self.pokedex.seen?+.
  def seen?(species)
    return @pokedex.seen?(species)
  end

  # (see Pokedex#owned?)
  # Shorthand for +self.pokedex.owned?+.
  def owned?(species)
    return @pokedex.owned?(species)
  end
end
