module VMS
  # Usage: VMS.interact_with_player(id #<Integer>) (interacts with the specified player)
  def self.interact_with_player(id)
    return unless VMS.is_connected? # Not connected
    # Get player
    player = VMS.get_player(id)
    return if player.nil? # Player doesn't exist
    player_name = player.name
    # Check state
    case player.state[0]
    when :idle
      VMS.send_interaction(player)
    when :interact_receive
      if player.state[1] == $player.id # Other player is interacting with us
        VMS.send_interaction(player)
      else # The other player is interacting with someone else
        pbMessage(_INTL("{1} is already interacting with someone else.", player_name))
      end
    when :interact_send
      if player.state[1] == $player.id # Other player is interacting with us
        VMS.check_interaction(player)
      else # The other player is interacting with someone else
        pbMessage(_INTL("{1} is already interacting with someone else.", player_name))
      end
    when :battle
      pbMessage(_INTL("{1} is in a battle.", player_name))
    when :trade
      pbMessage(_INTL("{1} is trading.", player_name))
    end
  end

  # Usage: VMS.check_interaction(player #<VMS::Player>) (checks if the specified player is interacting with the player)
  def self.check_interaction(player)
    return unless player.state.is_a?(Array)
    return if player.state[1] != $player.id
    return if $game_temp.vms[:state][0] == :interact_receive
    player_name = player.name
    # Check state
    if player.state[0] == :interact_send
      # Set state to interact with player
      $game_temp.vms[:state] = [:interact_receive, player.id]
      # Tell player to interact with us
      pbMessage(_INTL("{1} wants to interact with you!\\wtnp[20]", player_name))
      # Wait for other player to say something
      if !VMS.await_player_state(player, :interact_send, _INTL("Waiting for {1} to say something...", player_name), true, false, true)
        if player.state[1] != $player.id
          pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
          $game_temp.vms[:state] = [:idle, nil]
          return
        end
      end
      # Wait until the other player is done interacting with us
      while player.state[0] == :interact_send
        # Update the scene
        VMS.scene_update
        # Check if player still exists
        player = VMS.get_player(player.id)
        if player.nil?
          pbMessage(_INTL("{1} disconnected...", player_name))
          $game_temp.vms[:state] = [:idle, nil]
          return
        end
        # Check for cancellation
        break if VMS::INTERACTION_WAIT <= 0 && Input.trigger?(Input::BACK)
      end
      # Check what the player said
      case player.state[0]
      when :idle
        $game_temp.vms[:state] = [:idle, nil]
        pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
      when :interact_send
        pbMessage(_INTL("{1} is somehow still waiting for you to say something...", player_name))
        VMS.check_interaction(player)
      when :interact_receive

      when :interact_switch
        pbMessage(_INTL("{1} wants you to talk to them.\\wtnp[20]", player_name))
        VMS.send_interaction(player, true)
      when :trade
        if pbConfirmMessage(_INTL("{1} would like to trade.\\wt[10] Do you accept?", player_name))
          $game_temp.vms[:state] = [:trade, player.id]
          if !VMS.await_player_state(player, :trade, _INTL("Waiting for {1} to respond...", player_name))
            if player.state[1] != $player.id
              pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
              return
            end
          end
          VMS.start_trade(player)
        else
          $game_temp.vms[:state] = [:idle, nil]
        end
      when :battle
        if pbConfirmMessage(_INTL("{1} would like to battle.\\wt[10] Do you accept?", player_name))
          $game_temp.vms[:state] = [:battle, player.id]
          if !VMS.await_player_state(player, :battle, _INTL("Waiting for {1} to respond...", player_name))
            if player.state[1] != $player.id
              pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
              return
            end
          end
          VMS.start_battle(player)
        else
          $game_temp.vms[:state] = [:idle, nil]
        end
      end
      $game_temp.vms[:state] = [:idle, nil]
    end
  end

  # Usage: VMS.send_interaction(player #<VMS::Player>) (sends an interaction request to the specified player)
  def self.send_interaction(player, no_busy_check=false)
    # Get player name
    player_name = player.name
    # Get player ID
    id = player.id
    # Check if player is busy
    if player.busy && !no_busy_check
      pbMessage(_INTL("{1} is busy.", player_name))
      return
    end
    # Log it
    log("Interacting with player #{player_name} (#{id})")
    # Set state to interact with player
    $game_temp.vms[:state] = [:interact_send, id]
    # Create wait message
    msgwindow = pbCreateMessageWindow
    msgwindow.letterbyletter = true
    msgwindow.text = _INTL("Waiting for {1} to respond...", player_name)
    # Wait for other player to respond
    VMS.get_interaction_time.times do
      # Update the scene (so the message window doesn't freeze)
      VMS.scene_update
      msgwindow.update
      # Check if player still exists
      player = VMS.get_player(id)
      if player.nil?
        # Stop waiting
        pbDisposeMessageWindow(msgwindow)
        pbMessage(_INTL("{1} disconnected...", player_name))
        $game_temp.vms[:state] = [:idle, nil]
        return
      end
      # Check for cancellation
      break if VMS::INTERACTION_WAIT <= 0 && Input.trigger?(Input::BACK)
      # Check if player has responded
      break if player.state[1] == $player.id
    end
    pbDisposeMessageWindow(msgwindow) # Dispose message window
    # Check if player has responded
    if player.state[1] != $player.id
      # Set state to idle
      $game_temp.vms[:state] = [:idle, nil]
      pbMessage(_INTL("{1} did not respond.", player_name))
      return
    end
    # What do we do now?
    choice = pbMessage(_INTL("What would you like to do?"), ["Swap", "Trade", "Battle", "Cancel"])
    case choice
    when 0 # Swap
      # Set state to interact with player
      $game_temp.vms[:state] = [:interact_switch, id]
      # Tell player to interact with us
      pbMessage(_INTL("You want to interact with {1}!\\wtnp[20]", player_name))
      # Wait for other player to say something
      if !VMS.await_player_state(player, :interact_send, _INTL("Waiting for {1} to start talking...", player_name))
        if player.state[1] != $player.id
          pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
          $game_temp.vms[:state] = [:idle, nil]
          return
        end
      end
      # Start interacting with the player
      VMS.check_interaction(player)
    when 1 # Trade
      # Set state to trade with player
      $game_temp.vms[:state] = [:trade, id]
      if !VMS.await_player_state(player, :trade, _INTL("Waiting for {1} to respond...", player_name))
        if player.state[1] != $player.id
          pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
          return
        end
      end
      VMS.start_trade(player)
    when 2 # Battle
      # Set state to battle with player
      $game_temp.vms[:state] = [:battle, id]
      if !VMS.await_player_state(player, :battle, _INTL("Waiting for {1} to respond...", player_name))
        if player.state[1] != $player.id
          pbMessage(_INTL("{1} is no longer interacting with you. What a shame...", player_name))
          return
        end
      end
      VMS.start_battle(player)
    when 3 # Cancel
      # Set state to idle
      $game_temp.vms[:state] = [:idle, nil]
    end
    $game_temp.vms[:state] = [:idle, nil]
  end

  # Usage: VMS.create_event(map_id #<Integer>, id #<Integer>) (creates an event for the specified player)
  def self.create_event(map_id, id)
    rf_event = Rf.create_event(map_id) do |event|
      # Default
      event.x = 0
      event.y = 0
      event.name = "vms_player_#{id}"
      # Create page
      page = RPG::Event::Page.new
      page.list.clear
      page.trigger = 0
      list = page.list
      # Add behavior
      Compiler.push_script(list, "VMS::INTERACTION_PROC.call(#{id}, VMS.get_player(#{id}), get_self)")
      Compiler.push_end(list)
      # Save
      event.pages = [page]
    end
    rf_event[:event].name = "vms_player_#{id}"
    return rf_event
  end

  # Usage: VMS.check_timeout(player #<VMS::Player>) (checks if the specified player has timed out)
  def self.check_timeout(player)
    stored = ("stored_heartbeat_" + player.id.to_s).to_sym
    same_timer = ("same_timer_" + player.id.to_s).to_sym
    if $game_temp.vms[stored].nil?
      $game_temp.vms[stored] = player.heartbeat
      $game_temp.vms[same_timer] = 0
      return
    end
    if $game_temp.vms[stored] == player.heartbeat
      if $game_temp.vms[same_timer] > (VMS::TIMEOUT_SECONDS / 5)
        VMS.log("Player #{player.name} (#{player.id}) timed out.")
        Rf.delete_event(player.rf_event) if VMS.event_deletion_possible?(player)
        $game_temp.vms[:players].delete(player.id)
      end
      $game_temp.vms[same_timer] += Graphics.delta
    else
      $game_temp.vms[same_timer] = 0
    end
    $game_temp.vms[stored] = player.heartbeat
  end

  # Usage: VMS.player_still_connected(id #<Integer>, msgwindow #<MessageWindow>, show_message #<Boolean>) (checks if the specified player is still connected)
  def self.player_still_connected(id, msgwindow=nil, show_message=true)
    player = VMS.get_player(id)
    if player.nil?
      pbDisposeMessageWindow(msgwindow) unless msgwindow.nil?
      $game_temp.vms[:state] = [:idle, nil]
      pbMessage(_INTL("There appears to be a connection issue...\\wtnp[20]")) if show_message
      return nil
    end
    return player
  end

  # Usage: VMS.await_player_state(player #<VMS::Player>, state #<Symbol>, message #<String>, vms_updates #<Boolean>, indefinite #<Boolean>) (waits for the specified player to be in the specified state)
  def self.await_player_state(player, state=:idle, message="", vms_updates=true, indefinite=false, not_in_state = false)
    # Create wait message
    if !message.nil? && message != ""
      msgwindow = pbCreateMessageWindow
      msgwindow.letterbyletter = true
      msgwindow.text = message
    end
    # Wait for other player to respond
    VMS.get_interaction_time.times do
      # Update the scene (so the message window doesn't freeze)
      VMS.scene_update(vms_updates)
      msgwindow.update unless msgwindow.nil?
      # Check if player still exists
      player = VMS.player_still_connected(player.id, msgwindow, false)
      # Compare states
      if player.nil? || player.state[1] != $player.id || ((VMS::INTERACTION_WAIT <= 0 || indefinite) && Input.trigger?(Input::BACK))
        # Dispose message window
        pbDisposeMessageWindow(msgwindow) unless msgwindow.nil?
        # Set state to idle
        $game_temp.vms[:state] = [:idle, nil]
        return false
      end
      # Check if player is still in the specified state
      if not_in_state
        break if player.state[0] != state
      else
        break if player.state[0] == state
      end
    end
    # Dispose message window
    pbDisposeMessageWindow(msgwindow) unless msgwindow.nil?
    if not_in_state
      return true if player.state[0] != state
    else
      return true if player.state[0] == state # Return true if player is in the specified state
    end
    # Player is not in the specified state
    $game_temp.vms[:state] = [:idle, nil]
    return false
  end

  # Usage: VMS.update_party(player #<VMS::Player>) (updates the player's party)
  def self.update_party(player)
    new_party = []
    player.party.each do |pkmn|
      new_party.push(pkmn.is_a?(::Pokemon) ? pkmn : VMS.dehash_pokemon(pkmn))
    end
    player.party = new_party
    return player.party
  end

  # Usage: VMS.sync_animations(player #<VMS::Player>) (syncs the player's animations)
  def self.sync_animations(player)
    return unless VMS.is_connected?
    return if VMS::SYNC_ANIMATIONS == [0]
    return if player.nil?
    return if player.id == $player.id && !VMS::SHOW_SELF
    return unless $scene.is_a?(Scene_Map)
    return unless $scene.spriteset
    return if player.animation.nil? || player.animation.empty?
    player.animation.each do |anim|
      next if anim.nil?
      next if anim == 0
      next unless anim[1] == $game_map.map_id
      next unless VMS::SYNC_ANIMATIONS.include?(anim[0])
      next if $scene.spriteset.animationExists?(anim[0], anim[2], anim[3], anim[4], anim[5])
      $scene.spriteset.addUserAnimation(anim[0], anim[2], anim[3], anim[4], anim[5], false)
    end
  end

  # Usage: VMS.handle_player(player #<VMS::Player>) (handles the specified player)
  def self.handle_player(player)
    # Update party
    VMS.update_party(player)
    # Sync animations
    VMS.sync_animations(player)
    # No event
    return if player.rf_event.nil?
    # Update event
    player.rf_event[:event].x = player.x
    player.rf_event[:event].y = player.y
    player.rf_event[:event].direction = player.direction
    player.rf_event[:event].pattern = player.pattern
    player.rf_event[:event].character_name = player.graphic
    player.rf_event[:event].opacity = player.opacity
    player.rf_event[:event].step_anime = player.stop_animation
    player.rf_event[:event].through = VMS::THROUGH
    player.rf_event[:event].jumping_on_spot = player.jumping_on_spot
    player.rf_event[:event].x_offset = player.offset_x
    player.rf_event[:event].y_offset = player.offset_y - player.jump_offset
    player.rf_event[:event].real_x = player.real_x
    player.rf_event[:event].real_y = player.real_y
    # Make event invisible if it is farther than 10 tiles away
    distance = $map_factory.getRelativePos($game_map.map_id, $game_player.x, $game_player.y, player.map_id, player.x, player.y)
    distanceNorm = Math.sqrt(distance[0] ** 2 + distance[1] ** 2)
    player.rf_event[:event].opacity = 0 if distance[0].abs > 10 || distance[1].abs > 10 || distanceNorm > 10
    # Refresh event
    player.rf_event[:event].refresh
  end
end