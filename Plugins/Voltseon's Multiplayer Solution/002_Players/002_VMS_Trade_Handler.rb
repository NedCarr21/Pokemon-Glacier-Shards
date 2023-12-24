module VMS
  # Usage: VMS.start_trade(player #<VMS::Player>) (starts a trade with the specified player)
  def self.start_trade(player)
    begin
      # Get player name
      player_name = player.name
      # Check if the player is connected to the server.
      if !VMS.is_connected?
        pbMessage(_INTL("You are not connected to the server."))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Check if the player has any tradable Pokémon.
      if $player.able_pokemon_trade_count == 0
        pbMessage(_INTL("You don't have any tradable Pokémon."))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Check if the other player has any tradable Pokémon.
      party = VMS.update_party(player)
      if party.each { |pkmn| !pkmn.egg? && !pkmn.shadowPokemon? }.length == 0
        pbMessage(_INTL("{1} doesn't have any tradable Pokémon.", player.name))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Start trade
      pbChoosePokemon(1, 3, proc { |pkmn| !pkmn.egg? && !pkmn.shadowPokemon? })
      # Store variables
      pokemon_index = $game_variables[1]
      pokemon_name = $game_variables[3]
      # Check if the player selected a Pokémon.
      if pokemon_index == -1
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      $game_temp.vms[:state] = [:trade_confirm, player.id, pokemon_index, pokemon_name]
      # Wait for the other player to select a Pokémon.
      if !VMS.await_player_state(player, :trade_confirm, _INTL("Waiting for {1} to select a Pokémon...", player_name), true, true)
        pbMessage(_INTL("{1} doesn't want to trade anymore. What a shame...", player.name))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Store variables
      party = VMS.update_party(player)
      trade_pokemon_index = player.state[2]
      trade_pokemon_name = player.state[3]
      trade_pokemon = party[trade_pokemon_index]
      # Check if the other player selected a Pokémon.
      if trade_pokemon_index == -1
        pbMessage(_INTL("{1} doesn't want to trade anymore. What a shame...", player.name))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Confirm trade
      choices = [_INTL("Confirm Trade"), _INTL("Check my Pokémon"), _INTL("Check {1}'s Pokémon", player.name), _INTL("Cancel")]
      loop do
        choice = pbMessage(_INTL("Are you sure you want to trade {1} for {2}?", pokemon_name, trade_pokemon_name), choices, -1)
        case choice
        when 0 # Confirm trade
          $game_temp.vms[:state] = [:trade_accept, player.id, pokemon_index, pokemon_name]
          break
        when 1 # Check my Pokémon
          pbFadeOutIn do
            summary_scene = PokemonSummary_Scene.new
            summary_screen = PokemonSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([$player.party[pokemon_index]], 0)
          end
          next
        when 2 # Check other player's Pokémon
          pbFadeOutIn do
            summary_scene = PokemonSummary_Scene.new
            summary_screen = PokemonSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([trade_pokemon], 0)
          end
          next
        when 3 # Cancel
          $game_temp.vms[:state] = [:idle, nil]
          return
        end
      end
      # Wait for the other player to select a Pokémon.
      if !VMS.await_player_state(player, :trade_accept, _INTL("Waiting for {1} to accept.", player_name), true, true)
        pbMessage(_INTL("{1} doesn't want to trade anymore.", player.name))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Commence trade
      $game_temp.vms[:state] = [:idle, nil]
      pbStartTrade(pokemon_index, trade_pokemon, trade_pokemon_name, player.name)
      # Save the game to prevent duplicate Pokémon.
      if Game.save
        pbMessage("\\se[]" + _INTL("{1} saved the game.", $player.name) + "\\me[GUI save game]\\wtnp[30]")
      else
        pbMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
      end
    end
  rescue
    VMS.log("An error occurred whilst trading.", true)
    pbMessage(_INTL("An error occurred."))
  end
end