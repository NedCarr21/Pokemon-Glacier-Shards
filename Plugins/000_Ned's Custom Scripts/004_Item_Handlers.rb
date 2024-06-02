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
