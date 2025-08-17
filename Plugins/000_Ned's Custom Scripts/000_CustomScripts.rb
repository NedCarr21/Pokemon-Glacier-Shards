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
  $game_variables[91] = $player.pokedex.seen_count(1)
  $game_variables[92] = $player.pokedex.owned_count(1)
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
# Finding Money
#-------------------------------------------------------------------------------

    def gs_findCurrency(type, amount)
      validate amount => Integer
      if (type == :money)
        $player.money += amount
        $game_variables[85] += amount
        text = ["Money Found!", "$"]
      elsif (type == :coins)
        $player.coins += amount
        text = ["Coins Found!", ""]
      else
        text = ["", ""]
      end
      pbNotify(text[0], _INTL("{1}{2}", text[1], amount.to_s), 1, ["Graphics/UI/money_bag",266,28])
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
    if ($game_switches[61]) # if randomizer
      gsRegionalArray = pbAllRegionalSpecies(0)
      pkmn.species = gsRegionalArray.sample
      pkmn.form = rand(0..1) if Settings::GS_ALTERNATE_FORMS.include?(pkmn)
      pkmn.ability = gsRandomabil if $game_switches[61]
      pkmn.calc_stats
      pkmn.reset_moves
    end
  }
)

EventHandlers.add(:on_trainer_load, :gs_randomizer,
  proc { |trainer|
    if trainer && ($game_switches[61]) # if randomizer
      gsRegionalArray = pbAllRegionalSpecies(0)
      trainer.party.each { |pkmn|
        pkmn.species = gsRegionalArray.sample
        pkmn.form = rand(0..1) if Settings::GS_ALTERNATE_FORMS.include?(pkmn)
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
  pkmn.form = rand(0..1) if Settings::GS_ALTERNATE_FORMS.include?(pkmn)
  pkmn.calc_stats
  pkmn.reset_moves
  return pkmn
end

def gsRandomabil
  abils = []
  GameData::Ability.each do |ability|
    abils.push(ability.id)
  end
  return abils.sample
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
    if trainer
      trainer.party.each { |pkmn|
        pkmn.nature = Settings::SPECIALNATURES.sample if rand(10) == 0
        GameData::Stat.each_main do |s|
          pkmn.iv[s.id] += rand(2..5)
        end
        pkmn.calc_stats
        for pokemon in trainer.party do
          pokemon = pkmn
        end
      }
    end
})
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

EventHandlers.add(:on_frame_update, :player_x_y,
  proc {
    if $game_player
      $game_variables[51] = $game_player.x
      $game_variables[52] = $game_player.y
    end
  }
)

def gsCheckX(x)
  return (x == $game_variables[51])
end

def gsCheckY(y)
  return (y == $game_variables[52])
end

#-------------------------------------------------------------------------------
# Shiny Chance based on Guild Tier
#-------------------------------------------------------------------------------

EventHandlers.add(:on_frame_update, :shiny_chance_guild_tier,
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

GS_TEXT = { # starting x value (top left), width of character
  "A" => [0, 14],
  "B" => [16, 14],
  "C" => [32, 14],
  "D" => [48, 14],
  "E" => [64, 14],
  "F" => [80, 14],
  "G" => [96, 14],
  "H" => [112, 14],
  "I" => [128, 6],
  "J" => [136, 14],
  "K" => [152, 14],
  "L" => [168, 12],
  "M" => [182, 14],
  "N" => [198, 16],
  "O" => [216, 14],
  "P" => [232, 14],
  "Q" => [248, 14],
  "R" => [264, 14],
  "S" => [280, 14],
  "T" => [296, 14],
  "U" => [312, 14],
  "V" => [328, 14],
  "W" => [344, 14],
  "X" => [360, 14],
  "Y" => [376, 14],
  "Z" => [392, 14],
  "a" => [408, 14],
  "b" => [424, 14],
  "c" => [440, 14],
  "d" => [456, 14],
  "e" => [472, 14],
  "f" => [488, 14],
  "g" => [504, 14],
  "h" => [520, 14],
  "i" => [536, 6],
  "j" => [544, 10],
  "k" => [556, 14],
  "l" => [572, 6],
  "m" => [580, 18],
  "n" => [600, 14],
  "o" => [616, 14],
  "p" => [632, 14],
  "q" => [648, 14],
  "r" => [664, 12],
  "s" => [678, 14],
  "t" => [694, 12],
  "u" => [708, 14],
  "v" => [724, 14],
  "w" => [740, 14],
  "x" => [756, 14],
  "y" => [772, 14],
  "z" => [788, 14],
  "1" => [804, 14],
  "2" => [820, 14],
  "3" => [836, 14],
  "4" => [852, 14],
  "5" => [868, 14],
  "6" => [884, 14],
  "7" => [900, 14],
  "8" => [916, 14],
  "9" => [932, 14],
  "0" => [948, 14],
  ":" => [962, 10],
  "(" => [972, 8],
  "/" => [982, 10],
  ")" => [994, 8],
  "é" => [1004, 14],
  "+" => [1020, 14],
  "-" => [1036, 14],
  "=" => [1052, 14],
  "*" => [1068, 14],
  "_" => [1084, 14],
  "▲" => [1100, 14],
  "▼" => [1116, 14],
  "%" => [1130, 16],
  "." => [1146, 10],
  "$" => [1156, 16]
}

GS_FILE = _INTL("Graphics/UI/gs_text")

def gs_drawText(string, start_x, start_y, bitmap, width = 512)
  thisLine_x = start_x
  thisLine_y = start_y
  lines = []
  # get file bitmap
  file_bitmap = AnimatedBitmap.new(pbBitmapName(GS_FILE))
  # split up string into array of words
  str_array = string.split(" ")
  string_array = str_array.reject { |str| str.strip.empty? }
  # start loop through string
  string_array.length.times do |i|
    word = str_array[i]
    word_width = 0
    # start loop through each word
    word.each_char do |char|
      next unless GS_TEXT.key?(char)
      text_arr = GS_TEXT[char]
      # get length of word in pixels
      word_width += (text_arr[1] - 2)
      word_width = 0 if word_width < 0
    # end loop of each word
    end
    # check if length of word can be displayed on current line, if not increment line, and reset thisLine_x
    if (thisLine_x + word_width > width) # can not be displayed
      thisLine_y += 32 # increment the line, reset the thisLine_x
      thisLine_x = start_x
    end
    word.each_char do |char| # display word into the bitmap
      next unless GS_TEXT.key?(char)
      text_arr = GS_TEXT[char]
      char_rect = Rect.new(text_arr[0], 0, text_arr[1], 26)
      bitmap.blt(thisLine_x, thisLine_y, file_bitmap.bitmap, char_rect)
      thisLine_x += (text_arr[1] - 2)
    end
    thisLine_x += 6 # account for " " spaces in text
    #thisLine_x += word_width
  end
end

def demo_claw_machine(pokemon = $player.party[0])
  result = ClawMachineSystem.perform_claw_pull($player, pokemon)
  if result[:success]
    puts "Claw Machine pull successful! You got #{result[:reward]}"
    puts "The reward was shiny!" if result[:shiny_reward]
    puts "Coins spent: #{result[:cost]}"
  else
    puts "Claw Machine pull failed: #{result[:error]}"
  end
end


def demo_iv_numbers(input = 6, guild_level = $player.guild_data[:level], iv_stat_limit = 61)
  # generate return hash
  ret = {}
  procd = 0
  for a in 0..input do
    num = (rand(iv_stat_limit - 10)) / 7.floor
    for i in 1..guild_level do
      break if num >= iv_stat_limit
      next unless [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19].include?(rand(1..35))
      num += 1
      procd += 1
    end
    ret[a] = [[num, iv_stat_limit].min, 0].max
  end
  # amount of each iv number
  amt_of_each_num = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  ret.each do |key, value|
    amt_of_each_num[value] += 1
  end
  arr = amt_of_each_num #.reject { |n| n == 0 }
  puts "#{arr} => #{arr.length - 1} : procd: #{procd}"
end
