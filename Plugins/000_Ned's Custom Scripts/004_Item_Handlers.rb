ItemHandlers::UseOnPokemon.add(:LINKINGCORD, proc { |item, qty, pkmn, scene|
  if pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  candidates = pkmn.species_data.get_evolutions(true)
  candidates = candidates.filter_map {|species,method,_| GameData::Species.get(species) if [:Trade,:TradeItem,:TradeSpecies].include?(method)}
  candidates = candidates.uniq
  if candidates.length == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif candidates.length == 1
    newspecies = candidates[0]
  else
    choices = candidates.map { |species| species.name }
    choices << _INTL("Cancel")
    choice = scene.pbShowCommands(_INTL("Which evolution to take?"), choices, candidates.length)
    if choice == -1 || choice == candidates.length
      next false
    end
    newspecies = candidates[choice]
  end
  if newspecies
    choice = scene.pbShowCommands(_INTL("Evolve into {1}?", newspecies.name), ["Yes", "No"], 1)
    if choice == -1 || choice == 1
      next false
    end
    pbFadeOutInWithMusic {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn, newspecies.id)
      evo.pbEvolution(false)
      evo.pbEndScreen
    }
    next true
  end
})

ItemHandlers::UseOnPokemonMaximum.add(:HP_CANDY_SMALL, proc { |item, qty, pkmn, scene|
  item_split = item.to_s.split("_")
  stat = item_split[0].to_sym

  case item_split[2].to_sym
  when :SMALL
    next 20 - pkmn.iv[stat]
  when :MEDIUM
    next 40 - pkmn.iv[stat]
  when :LARGE
    next 60 - pkmn.iv[stat]
  end
})

ItemHandlers::UseOnPokemonMaximum.copy(
  :HP_CANDY_SMALL, :HP_CANDY_MEDIUM, :HP_CANDY_LARGE,
  :ATTACK_CANDY_SMALL, :ATTACK_CANDY_MEDIUM, :ATTACK_CANDY_LARGE,
  :DEFENSE_CANDY_SMALL, :DEFENSE_CANDY_MEDIUM, :DEFENSE_CANDY_LARGE,
  :SPECIAL_ATTACK_CANDY_SMALL, :SPECIAL_ATTACK_CANDY_MEDIUM, :SPECIAL_ATTACK_CANDY_LARGE,
  :SPECIAL_DEFENSE_CANDY_SMALL, :SPECIAL_DEFENSE_CANDY_MEDIUM, :SPECIAL_DEFENSE_CANDY_LARGE,
  :SPEED_CANDY_SMALL, :SPEED_CANDY_MEDIUM, :SPEED_CANDY_LARGE
)

ItemHandlers::UseOnPokemon.add(:HP_CANDY_SMALL, proc { |item, qty, pkmn, scene|
  item_split = item.to_s.split("_")
  stat = item_split[0].to_sym

  case item_split[2].to_sym
  when :SMALL
    if (pkmn.iv[stat] + qty > 20)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
  when :MEDIUM
    if (pkmn.iv[stat] + qty > 40)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
  when :LARGE
    if (pkmn.iv[stat] + qty > 60)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
  end

  stat = GameData::Stat.get(stat)
  item = GameData::Item.try_get(item)
  if qty > 1
    choice = scene.pbShowCommands(_INTL("Would you like to raise {1}\'s {2} IVs by {3}?", pkmn.name, stat.name, qty.to_s), ["Yes", "No"], 0)
  else
    choice = scene.pbShowCommands(_INTL("Would you like to raise {1}\'s {2} IVs?", pkmn.name, stat.name), ["Yes", "No"], 0)
  end
  if choice == -1 || choice == 1
    next false
  end
  pkmn.iv[stat.id] += qty
  pkmn.calc_stats
  scene.pbDisplay(_INTL("{1}\'s {2} IVs were raised by {3}", pkmn.name, stat.name, qty.to_s))
  next true
})

ItemHandlers::UseOnPokemon.copy(
  :HP_CANDY_SMALL, :HP_CANDY_MEDIUM, :HP_CANDY_LARGE,
  :ATTACK_CANDY_SMALL, :ATTACK_CANDY_MEDIUM, :ATTACK_CANDY_LARGE,
  :DEFENSE_CANDY_SMALL, :DEFENSE_CANDY_MEDIUM, :DEFENSE_CANDY_LARGE,
  :SPECIAL_ATTACK_CANDY_SMALL, :SPECIAL_ATTACK_CANDY_MEDIUM, :SPECIAL_ATTACK_CANDY_LARGE,
  :SPECIAL_DEFENSE_CANDY_SMALL, :SPECIAL_DEFENSE_CANDY_MEDIUM, :SPECIAL_DEFENSE_CANDY_LARGE,
  :SPEED_CANDY_SMALL, :SPEED_CANDY_MEDIUM, :SPEED_CANDY_LARGE
)
