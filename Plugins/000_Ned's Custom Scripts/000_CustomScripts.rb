#-------------------------------------------------------------------------------
#
#
#
#
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Overworld Battle Maker (unused atm)
#-------------------------------------------------------------------------------

def gsRoamingBattle(species, minlevel, maxlevel)
    pkmn = GameData::Species.get(species).id
    level = rand(minlevel, maxlevel)
    Pokemon.play_cry(pkmn)
    pbWait(12)
    WildBattle.start(pkmn,level)
end

#-------------------------------------------------------------------------------
# Rare Pokédex Evaluation
#-------------------------------------------------------------------------------

def rareDexEval
  seen = 0
  owned = 0
  seen = $player.pokedex.seen_count(1)
  $game_variables[91] = seen
  owned = $player.pokedex.owned_count(1)
  $game_variables[92] = owned
end

def pkmn_in_party_location(pkmn1,map_id)
  for i in 0..$player.party.length
    pkmn = $player.party[i]
    if (pkmn = pkmn1 && pkmn.obtain_map = map_id)
      return true
    end # end of if
  end # end of for
    return false
end # end of def

#-------------------------------------------------------------------------------
# Random Rare Items
#-------------------------------------------------------------------------------

ITEMARR = [ #[:ITEM,MAXQUANTITY,WEIGHT]
  [:LUCKYEGG,1,1],
  [:RAREBONE,1,2],
  [:SWEETBAIT,3,2],
  [:SPECIALTYBAIT,1,1],
  [:SUPERPOTION,4,6],
  [:HYPERPOTION,2,4],
  [:MONOBALL,1,3],
  [:DUELBALL,1,2],
  [:SNOWBALLBALL,1,2],
  [:ULTRABALL,1,4],
  [:OMEGABALL,1,1],
  [:EXPCANDYM,2,3],
  [:EXPCANDYL,1,2],
  [:EXPCANDYXL,1,1],
  [:NUGGET,1,1],
  [:BIGNUGGET,1,1],
  [:PEARL,1,2],
  [:BIGPEARL,1,1],
  [:PEARLSTRING,1,1],
  [:STARPIECE,1,1],
  [:COMETSHARD,1,1],
  [:BIGMUSHROOM,1,2],
  [:BALMMUSHROOM,1,1],
  [:RARECANDY,1,2],
  [:HEARTSCALE,3,5]
]
  #[:ITEM,QUANTITY,WEIGHT]
  def randRareItem
    weightTotal = 0
    count = 0
    for i in 0..ITEMARR.length-1
      weightTotal += ITEMARR[i][2]
    end
      itemnum = rand(ITEMARR[1][2]..weightTotal)
      for n in 0..ITEMARR.length-1
        count += ITEMARR[n][2]
        if count > itemnum
          item = ITEMARR[n][0]
          quantity = rand(ITEMARR[n][1]/2.floor..ITEMARR[n][1])
          quantity = 1 if quantity < 1
          pbReceiveItem(item, quantity)
          break
        end
      end
  end

#-------------------------------------------------------------------------------
# Random Berries for Bushes
#-------------------------------------------------------------------------------

  BERRYARR = [ #[:ITEM,WEIGHT]
    [:ORANBERRY,12],
    [:SITRUSBERRY,6],
    [:CHERIBERRY,3],
    [:CHESTOBERRY,3],
    [:PECHABERRY,3],
    [:RAWSTBERRY,3],
    [:ASPEARBERRY,3],
    [:LEPPABERRY,3],
    [:PERSIMBERRY,3],
    [:LUMBERRY,3],
    [:FIGYBERRY,1],
    [:WIKIBERRY,1],
    [:MAGOBERRY,1],
    [:AGUAVBERRY,1],
    [:IAPAPABERRY,1],
    [:POMEGBERRY,2],
    [:KELPSYBERRY,2],
    [:QUALOTBERRY,2],
    [:HONDEWBERRY,2],
    [:GREPABERRY,2],
    [:TAMATOBERRY,2]
  ]
    #[:ITEM,WEIGHT]
    def randBerry
      weightTotal = 0
      count = 0
      for i in 0..BERRYARR.length-1
        weightTotal += BERRYARR[i][1]
      end
        berrynum = rand(BERRYARR[1][1]..weightTotal)
        for n in 0..BERRYARR.length-1
          count += BERRYARR[n][1]
          if count > berrynum
            berry = BERRYARR[n][0]
            quantity = rand(2..4)
            pbReceiveItem(berry, quantity)
            break
          end
        end
    end

#-------------------------------------------------------------------------------
# Give the player if they don't have many of this item.
#-------------------------------------------------------------------------------
    def notEnough(item=:ORANBERRY, count=5, enoughText="")
      if !$bag.has?(item, count)
        pbMessage(_INTL("Oh no, you don't seem to have many {1}, here, you can have some of mine!", item.name_plural))
        pbReceiveItem(item, count)
      else
        pbMessage(_INTL(enoughText))
      end
    end

#-------------------------------------------------------------------------------
# Special Shiny Rate Static Pokémon
#-------------------------------------------------------------------------------

  def gsShinyStatic(pkmn1=:BULBASAUR, level=5, shinychance=10)
      pkmn = Pokemon.new(pkmn1,level)
      if rand(0..shinychance) == 1
        pkmn.shiny = true
      end
      pkmn.nature = Settings::SPECIALNATURES.sample
      if pkmn1 == :ROTOM
        pbMessage(_INTL("The TV lights flickered."))
        $game_switches[75] = true
        Pokemon.play_cry(pkmn1)
        pbWait(0.2);
        WildBattle.start(pkmn)
      end # end of if :ROTOM
    end # end of def

  def gsCryDex(pkmn)
    $player.pokedex.set_seen(pkmn)
    Pokemon.play_cry(pkmn)
  end

#-------------------------------------------------------------------------------
# Randomizer
#-------------------------------------------------------------------------------

EventHandlers.add(:on_wild_pokemon_created, :gs_randomizer,
  proc { |pkmn|
    if ($game_switches[61] || ChallengeModes.on?(:RANDOMIZER)) # if randomizer
      gsRegionalArray = pbAllRegionalSpecies(0)
      pkmn.species = gsRegionalArray.sample
      if Settings::GS_ALTERNATE_FORMS.include?(pkmn)
        pkmn.form = rand(0..1)
      else
        pkmn.form = 0
      end
      pkmn.ability = gsRandomabil if $game_switches[61]

      pkmn.calc_stats
      pkmn.reset_moves
    end
  }
)

EventHandlers.add(:on_trainer_load, :gs_randomizer,
  proc { |trainer|
    if trainer && ($game_switches[61] || ChallengeModes.on?(:RANDOMIZER)) # if randomizer
      gsRegionalArray = pbAllRegionalSpecies(0)
      trainer.party.each { |pkmn|
        pkmn.species = gsRegionalArray.sample
        if Settings::GS_ALTERNATE_FORMS.include?(pkmn)
          pkmn.form = rand(0..1)
        else
          pkmn.form = 0
        end
        pkmn.ability = gsRandomabil if $game_switches[61]

        pkmn.calc_stats
        pkmn.reset_moves
        for pokemon in trainer.party do
          pokemon = pkmn
        end
        }
    end
  }
)

def gsRandompkmn
  pkmn = Pokemon.new(:BULBASAUR,5)
  gsRegionalArray = pbAllRegionalSpecies(0)
  pkmn.species = gsRegionalArray.sample
  if Settings::GS_ALTERNATE_FORMS.include?(pkmn)
    pkmn.form = rand(0..1)
  else
    pkmn.form = 0
  end
  pkmn.calc_stats
  pkmn.reset_moves
  return pkmn
end

def gsRandomabil
  ability = :INTIMIDATE
  abils = []

  GameData::Ability.each do |ability|
    abils.push(ability.id)
  end
  ability = abils.sample

  return ability
end

#-------------------------------------------------------------------------------
# Stat Berries on Wild Pokemon
#-------------------------------------------------------------------------------

EventHandlers.add(:on_wild_pokemon_created, :gs_wild_held_berries,
  proc { |pkmn|
        case rand(11)
          when 0..1; pkmn.item = :ORANBERRY
          when 2; pkmn.item = :SITRUSBERRY
        end
        if rand(250) == 1 # 1/250 chance
          case rand(5)
            when 0; pkmn.item = :MOLTENSTAGHORN
            when 1; pkmn.item = :SNOWMULBERRY
            when 2; pkmn.item = :FAIRYLILY
            when 3; pkmn.item = :INKBONNET
            when 4; pkmn.item = :SUNNYJOLTFRUIT
          end
        end
  }
)

#-------------------------------------------------------------------------------
# Difficulty Modes
#-------------------------------------------------------------------------------
EventHandlers.add(:on_trainer_load, :gs_difficulty,
  proc { |trainer|
    if trainer && $game_variables[84] == 2 # hard
      trainer.party.each { |pkmn|

        pkmn.nature = Settings::SPECIALNATURES.sample if rand(16)==0

        temp_stats = Settings::STATS.sample(2)
        pkmn.iv[temp_stats[0]] = rand(21..31)
        pkmn.iv[temp_stats[1]] = rand(21..31)

        pkmn.calc_stats
      for pokemon in trainer.party do
        pokemon = pkmn
      end

      Console.echo_li _INTL("{1} {2}", pkmn.species, pkmn.iv) if $DEBUG

      }
    end

    if trainer && $game_variables[84] == 3 # challenge
      trainer.party.each { |pkmn|

        pkmn.nature = Settings::SPECIALNATURES.sample if rand(8)==0

        temp_stats = Settings::STATS.sample(4)
        pkmn.iv[temp_stats[0]] = rand(21..31)
        pkmn.iv[temp_stats[1]] = rand(21..31)
        pkmn.iv[temp_stats[2]] = rand(21..31)
        pkmn.iv[temp_stats[3]] = rand(21..31)

        pkmn.calc_stats
      for pokemon in trainer.party do
        pokemon = pkmn
      end

      Console.echo_li _INTL("{1} {2}", pkmn.species, pkmn.iv) if $DEBUG

      }
    end
  }
)
#-------------------------------------------------------------------------------
# Ball Handlers / Catch Rates for Custom Pokeballs
#-------------------------------------------------------------------------------
Battle::PokeBallEffects::ModifyCatchRate.add(:OMEGABALL, proc { |ball, catchRate, battle, battler|
  next catchRate * 2.75
})

Battle::PokeBallEffects::ModifyCatchRate.add(:MONOBALL, proc { |ball, catchRate, battle, battler|
  multiplier = 3.5
  catchRate *= multiplier if battler.types[0] == battler.types[1]
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:DUELBALL, proc { |ball, catchRate, battle, battler|
  multiplier = 3.5
  catchRate *= multiplier if battler.types[0] != battler.types[1]
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:SNOWBALLBALL, proc { |ball, catchRate, battle, battler|
  multiplier = 3.5
  catchRate *= multiplier if battler.pbHasType?(:ICE)
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:GOLDENBALL, proc { |ball, catchRate, battle, battler|
  next catchRate * 0.33
})

Battle::PokeBallEffects::ModifyCatchRate.add(:UNOWNBALL, proc { |ball, catchRate, battle, battler|
  if battler.isSpecies?(:UNOWN)
    catchRate *= 3
  else
    catchRate /= 3
  end
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:LUCKBALL, proc { |ball, catchRate, battle, battler|
  next rand(255)
})

#-------------------------------------------------------------------------------
# Rock Climb
#-------------------------------------------------------------------------------



def gsRockClimb(length = 1)
  move = :ROCKCLIMB
  movefinder = $player.get_pokemon_with_move(move)
  if !$DEBUG && !movefinder
    pbMessage(_INTL("This rocky wall seems climbable. Maybe a Pokémon could scale it."))
    return false
  end
  if pbConfirmMessage(_INTL("This rocky wall seems climbable. Would you like to use Rock Climb?"))
    # $stats.rockclimb_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    h = length
    if $game_player.direction = 8 # facing UP
      # move the player UP the rocks
      pbMoveRoute($game_player,[PBMoveRoute::THROUGH_ON,
        PBMoveRoute::CHANGE_SPEED, 5])
      while h > 0
        pbMoveRoute($game_player,[PBMoveRoute::UP,
          PBMoveRoute::WAIT, 2])
        h -= 1
      end
      pbMoveRoute($game_player,[PBMoveRoute::THROUGH_OFF,
        PBMoveRoute::CHANGE_SPEED, 3])
    else # facing down
      # move the player down the rocks
      pbMoveRoute($game_player,[PBMoveRoute::THROUGH_ON,
        PBMoveRoute::CHANGE_SPEED, 5])
      while h > 0
        pbMoveRoute($game_player,[PBMoveRoute::DOWN,
          PBMoveRoute::WAIT, 2])
        h -= 1
      end
      pbMoveRoute($game_player,[PBMoveRoute::THROUGH_OFF,
        PBMoveRoute::CHANGE_SPEED, 3])
    end
    return true
  end
end

HiddenMoveHandlers::CanUseMove.add(:ROCKCLIMB, proc { |move, pkmn, showmsg|
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/rockclimb/i]
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:ROCKCLIMB, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    gsRockClimb
  end
  next true
})
#-------------------------------------------------------------------------------
# Natures
#-------------------------------------------------------------------------------

GameData::Nature.register({
  :id           => :UNDERWHELMING,
  :name         => _INTL("Underwhelming"),
  :stat_changes => [[:ATTACK, -5], [:DEFENSE, -5], [:SPECIAL_ATTACK, -5], [:SPECIAL_DEFENSE, -5], [:SPEED, -5]]
})

GameData::Nature.register({
  :id           => :PHENOMENAL,
  :name         => _INTL("Phenomenal"),
  :stat_changes => [[:ATTACK, 5], [:DEFENSE, 5], [:SPECIAL_ATTACK, 5], [:SPECIAL_DEFENSE, 5], [:SPEED, 5]]
})

GameData::Nature.register({
  :id           => :DESTRUCTIVE,
  :name         => _INTL("Destructive"),
  :stat_changes => [[:ATTACK, 20], [:DEFENSE, -5], [:SPECIAL_ATTACK, -5], [:SPECIAL_DEFENSE, -5], [:SPEED, -5]]
})

GameData::Nature.register({
  :id           => :BEEFY,
  :name         => _INTL("Beefy"),
  :stat_changes => [[:ATTACK, -5], [:DEFENSE, 20], [:SPECIAL_ATTACK, -5], [:SPECIAL_DEFENSE, -5], [:SPEED, -5]]
})

GameData::Nature.register({
  :id           => :ENCHANTING,
  :name         => _INTL("Enchanting"),
  :stat_changes => [[:ATTACK, -5], [:DEFENSE, -5], [:SPECIAL_ATTACK, 20], [:SPECIAL_DEFENSE, -5], [:SPEED, -5]]
})

GameData::Nature.register({
  :id           => :CHARISMATIC,
  :name         => _INTL("Charismatic"),
  :stat_changes => [[:ATTACK, -5], [:DEFENSE, -5], [:SPECIAL_ATTACK, -5], [:SPECIAL_DEFENSE, 20], [:SPEED, -5]]
})

GameData::Nature.register({
  :id           => :INSANE,
  :name         => _INTL("Insane"),
  :stat_changes => [[:ATTACK, -5], [:DEFENSE, -5], [:SPECIAL_ATTACK, -5], [:SPECIAL_DEFENSE, -5], [:SPEED, 20]]
})

#-------------------------------------------------------------------------------
# Player Coordinate Check
#-------------------------------------------------------------------------------

EventHandlers.add(:on_frame_Update, :player_x_y,
  proc {
    if $game_player
      $game_variables[51] = $game_player.x
      $game_variables[52] = $game_player.y
    end
  }
)

def gsCheckX(x)
  if x == $game_variables[51]
    return true
  else
    return false
  end
end

def gsCheckY(y)
  if y == $game_variables[52]
    return true
  else
    return false
  end
end

#-------------------------------------------------------------------------------
# Shiny Chance based on Guild Tier
#-------------------------------------------------------------------------------

EventHandlers.add(:on_frame_Update, :shiny_chance_guild_tier,
  proc {
    case $game_variables[90]
      when 0; Settings::SHINY_POKEMON_CHANCE = 16 # No Tier       = 1/4096     (with charm 1/2048)
      when 1; Settings::SHINY_POKEMON_CHANCE = 24 # Bronze Tier   = 1/2730.67  (with charm 1/1365.33)
      when 2; Settings::SHINY_POKEMON_CHANCE = 32 # Silver Tier   = 1/2048     (with charm 1/1024)
      when 3; Settings::SHINY_POKEMON_CHANCE = 40 # Gold Tier     = 1/1638.4   (with charm 1/819.2)
      when 4; Settings::SHINY_POKEMON_CHANCE = 48 # Platinum Tier = 1/1365.33  (with charm 1/682.67)
    end
  }
)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
=begin
EventHandlers.add(:on_frame_update, :glitch_title,
  proc {
    next if !$scene.is_a?(Scene_Map)
    next unless rand(800) == 1
    title = System.game_title
    weird = "S̵͉͝p̶͓͋a̸͍̽c̷͓̊e̶̬̽ ̷̬̆T̶̫̍r̷̙̋ȃ̷̲ḯ̶̞n̶̯̑e̷̗͠ȑ̶ͅŝ̴̝"
    jibberish = title.split("").map { |c| rand(2) == 1 ? c : rand(2) == 1 ? c.upcase : c.downcase }.join
    rand(1..5).times do
      index = rand(jibberish.size)
      jibberish[index] = weird[index]
    end
    jibberish = "code: titlename" if rand(200) == 1
    System.set_window_title(jibberish)
    rand(5..20).times do
      Graphics.update
      Input.update
      $scene.update
    end
    System.set_window_title(title)
  }
)
=end
