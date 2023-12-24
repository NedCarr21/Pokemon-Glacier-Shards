def pbIntroGreeting(trainerGender)
	if trainerGender == 0
		flavor = "\\b"
	else
		flavor = "\\r"
	end
	pbMessage(_INTL("{1}Hello there! Welcome to the Wonter Trade Service!", flavor))
	#ret = 
	#pbConfirmMessage(_INTL("{1}Would you like to hear an explanation of the service?", flavor))
	commands = [_INTL("Trade"), _INTL("Explanation"), _INTL("Exit")]
	choice = pbMessage(_INTL("What would you like to do?"), commands)
	if choice == 0
		pbMessage(_INTL("{1}Alright, let's get started", flavor))
	elsif choice == 1
		pbMessage(_INTL("{1}The Wonder Trade Service works by taking one of your Pokemon and trading it", flavor))
		pbMessage(_INTL("{1}for another Pokemon. It can be anything from a Common Pokemon like Pidgey, to ", flavor))
		pbMessage(_INTL("{1}a Legendary Pokemon like Mewtwo! The Pokemon you receive will be the same level", flavor))
		pbMessage(_INTL("{1}as the Pokemon you are trading. Exciting, isn't it?!", flavor))
	else
		pbMessage(_INTL("{1}Alright. Come back if you change your mind.", flavor))
	end
	return choice
end


def pbWonderTrade(nickName = nil, trainerName = nil, trainerGender = nil)
  blocklist = WonderTradeSettings::BLOCKLIST_POKEMON
  allowlist = WonderTradeSettings::ALLOWLIST_POKEMON
  chosen = -1
  if rand(100) < 50
    trainerName ||= WonderTradeSettings::MALE_NAMES.sample
	trainerGender ||= 0
  else
    trainerName ||= WonderTradeSettings::FEMALE_NAMES.sample
	trainerGender ||= 1
  end
  
  setArgs = nickName, trainerName, trainerGender
  choice = pbIntroGreeting(trainerGender)
  if choice == 0 || choice == 1
  pbFadeOutIn do
    scene = PokemonStorageScene.new
    screen = PokemonStorageScreen.new(scene, $PokemonStorage)
	@scene.pbMessage(_INTL("Choose a Pokemon for the Wonder Trade!"))
    chosen = screen.pbWonderTradeFromPC

  end
  
  if chosen.nil?
    pbMessage(_INTL("Come back later if you change your mind!"))
  else
    # Probability for rarity levels
    rarityProb = {
      common: 50,
      uncommon: 25,
      rare: 16,
      veryRare: 5,
      ultraRare: 3,
      legendary: 1
    }
    
    pokemonData = Hash.new(0)
    
	# Adds allowlist Pokemon into the pool
	allowlist.each do |species_id, chanceIncrease|
	  chanceIncrease ||= 1
	  pokemonData[species_id] += chanceIncrease
    end
	
    # Cycles through each encounter for map and version
    GameData::Encounter.each do |encounter|
      map = encounter.map
      version = encounter.version
      encounterData = GameData::Encounter.get(map, version)
      
      # If encounter data is found, cycle through them for species encountered
      if encounterData
        encounterData.types.each do |encounterType, speciesList|
          # Cycles through the species encounters to split out enc chance, species, min lvl, max lvl
          speciesList.each do |encounterChance, species, min, max|
		  # Skips blocklisted Pokemon
			next if blocklist.include?(species)
            # Counts the number of times a species is encountered
            pokemonData[species] += 1
          end
        end
      end
    end
    # Sorts the data by the number of times encountered
    sortedPokemonData = pokemonData.sort_by { |species, weight| -weight }
    
    # Splits the data into 6 equal sections, which populate the "rarities"
    rarities = sortedPokemonData.each_slice(sortedPokemonData.size / 6).to_a
    common, uncommon, rare, veryRare, ultraRare, legendary = rarities

    # Generate a random number between 0 and 100
    randomNumber = rand(100)
    
    # Initialize variables
    currentRange = 0
    selectedRarity = nil
    
    # Cycles through the rarity probabilities to find the selected rarity
    rarityProb.each do |rarity, probability|
      currentRange += probability
      if randomNumber < currentRange
        selectedRarity = rarity
        break
      end
    end
    
    selectedRaritySpecies = case selectedRarity
      when :common then common
      when :uncommon then uncommon
      when :rare then rare
      when :veryRare then veryRare
      when :ultraRare then ultraRare
      when :legendary then legendary
      else []
    end
    # Calculate the total weight for the selected rarity
    totalWeightRarity = selectedRaritySpecies.map { |species_id, weight| weight }.sum

    # Generate a random weight for picking rarities
    randomWeightRarity = rand(totalWeightRarity)

    # Initialize variables
    currentWeightRarity = 0
    chosenSpecies = nil

    # Iterate through the selected rarity species to find the chosen species
    selectedRaritySpecies.each do |species_id, weight|
      currentWeightRarity += weight
      if randomWeightRarity < currentWeightRarity
        chosenSpecies = species_id
        break
      end
    end

    if chosenSpecies
      speciesData = GameData::Species.get(chosenSpecies)
      speciesName = speciesData.species
    else
      puts "No Pokémon chosen."
    end
    
    pbWonderStartTrade(chosen, speciesName, setArgs)
  end
  else
  end
end

def pbWonderStartTrade(chosen, speciesName, setArgs)
  $stats.trade_count += 1
  
  myPokemon = $PokemonStorage[chosen[0]][chosen[1]]
  resetmoves = true
  trainerName = setArgs[1]
  trainerGender = setArgs[2]
  
  # Sets trainer name and trainer gender from argument, if passed.
  # If not passed, randomly pulls either a male or female name from the list, and sets gender accordingly.

  
  yourPokemon = Pokemon.new(speciesName, myPokemon.level)
  
  # Sets Pokemon nickname from arugment, if passed. If not, and settings use nickname is true, randomly selects from list
  # If argument isn't set, and setting is false, nickname will be the Pokemon's species
  yourPokemon.name = setArgs[0]
  if WonderTradeSettings::USE_NICKNAME
    if setArgs[0].nil?
	  yourPokemon.name = WonderTradeSettings::POKEMON_NICKNAMES.sample
	end
  end
  
  yourPokemon.owner = Pokemon::Owner.new_foreign(trainerName, trainerGender)
  yourPokemon.obtain_method = 2 # traded
  yourPokemon.reset_moves if resetmoves
  yourPokemon.record_first_moves

  if PluginManager.installed?("Charms Case")
    tradingCharmIV = CharmCaseSettings::TRADING_CHARM_IV
    if $player.activeCharm?(:TRADINGCHARM)
      GameData::Stat.each_main do |s|
        stat_id = s.id
        # Adds 5 IVs to each stat.
        yourPokemon.iv[stat_id] = [yourPokemon.iv[stat_id] + tradingCharmIV, 31].min if yourPokemon.iv[stat_id]
      end
      if rand(100) < CharmCaseSettings::TRADING_CHARM_SHINY
        yourPokemon.shiny = true
      end
    end
  end
  
  pbFadeOutInWithMusic do
    evo = PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon, yourPokemon, $player.name, trainerName)
    evo.pbTrade
    evo.pbEndScreen
  end

  $PokemonStorage[chosen[0]][chosen[1]] = yourPokemon
end



class PokemonStorageScreen
  def pbWonderTradeFromPC
    $game_temp.in_storage = true
    @heldpkmn = nil
    @scene.pbStartBox(self, 0)
    retval = nil
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected && selected[0] == -3   # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
		  pbMessage(_INTL("Come back if you want to try out the Wonder Trade!"))
          pbSEPlay("PC close")
          break
        end
        next
      end
      if selected.nil?
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0] == -4   # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0], selected[1]]
        next if !pokemon
        commands = [
          _INTL("Trade"),
          _INTL("Summary"),
        ]
        commands.push(_INTL("Debug")) if $DEBUG
        commands.push(_INTL("Cancel"))
        helptext = _INTL("{1} is selected.", pokemon.name)
        command = pbShowCommands(helptext, commands)
        case command
        when 0   # Select
			ret = pbConfirmMessage(_INTL("Are you sure you want to trade {1}?", pokemon.name))
            if ret
			  retval = selected
              break
			end
        when 1 # Summary
          pbSummary(selected, nil)
        when 2
          if $DEBUG
            pbPokemonDebug(pokemon, selected)
          end
        end
      end
    end
    @scene.pbCloseBox
    $game_temp.in_storage = false
	# Returns location in PC
    return retval
  end
end