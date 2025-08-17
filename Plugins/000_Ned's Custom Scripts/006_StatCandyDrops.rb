class StatCandyDropper
  # The level difference is capped between these values
  MAX_LEVEL_DIFF = 25  # Max boost if opponent is 25+ levels above player
  MIN_LEVEL_DIFF = -5  # No scaling reward if player is 5+ levels above opponent

  @drops = {}

  EventHandlers.add(:on_end_battle, :grant_stat_candies,
    proc { |decision, canLose|
      if decision == 1 # Win=1, Lose=2, Capture=4, Draw=5
        if !@drops.empty?
          # Grant the items
          @drops.each do |item, amount|
            Console.echo_li _INTL("Dropping Candy: " + item.to_s + " x" + amount.to_s + "\n")
            pbReceiveItem(item, amount)
          end
          @drops = {}
        end
      end
    }
  )

  # Calculates the average level difference between player and opponent
  def self.get_level_diff(player_levels, opponent_levels)
    p_levels = player_levels
    p_levels = Array.new(1, player_levels) if player_levels.is_a?(Integer)
    o_levels = opponent_levels
    o_levels = Array.new(1, opponent_levels) if opponent_levels.is_a?(Integer)
    avg_player = average_level(p_levels)
    avg_opp = average_level(o_levels)
    # Clamp the difference between MIN and MAX to avoid over-scaling
    (avg_opp - avg_player).clamp(MIN_LEVEL_DIFF, MAX_LEVEL_DIFF)
  end

  # Simple average calculation
  def self.average_level(levels)
    return 0 if levels.empty?
    levels.sum / levels.size.to_f
  end

  # Determines candy size based on the level difference
  def self.get_candy_size(level_diff)
    # Convert level_diff (-5 to 25) to a 0.0–0.75 scale
    chance = [(level_diff + 5) / 30.0, 0.75].min
    # 20% of this chance to go directly to large (max 15%)
    return :large if rand < chance * chance
    # Else, chance to get a medium candy (up to 75%)
    return :medium if rand < chance
    # Default is small if neither succeed
    return :small
  end

  def self.add_candy(idxParty, defeatedBattler)
    evYield = defeatedBattler.pokemon.evYield
    Console.echo_li _INTL("[CandyDropper] Initializing Candy..." + "\n")
    player_levels = pbBalancedLevel($player.party)
    # Opponent average: all enemies
    enemy_levels = defeatedBattler.pokemon.level
    level_diff = get_level_diff(player_levels, enemy_levels)
    Console.echo_li _INTL("[CandyDropper] Got Level Difference:" + level_diff.to_s + "\n")
    Console.echo_li _INTL("[CandyDropper] For Pokemon: " + defeatedBattler.pokemon.name + "\n")
    GameData::Stat.each_main do |s|
      ev_amount = evYield[s.id]
      next if (ev_amount <= 0)
      size = get_candy_size(level_diff)
      item_sym = "#{s.id}_candy_#{size}".upcase.to_sym
      Console.echo_li _INTL("[CandyDropper] Loading Candy: " + item_sym.to_s + "\n")
      @drops[item_sym] = 1
      if ev_amount >= 2 && rand < 0.7  # 70% for 2nd candy
        @drops[item_sym] += 1
      end
      if ev_amount >= 3 && rand < 0.5  # 50% for 3rd candy (only if already passed 2nd)
        @drops[item_sym] += 1
      end
    end # end of do
  end # end of def
end # end of Class
