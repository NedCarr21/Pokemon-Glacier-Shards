module ClawMachineTimeHelper
  def self.current_hour
    pbGetTimeNow.hour
  end

  def self.current_date_string
    pbGetTimeNow.strftime("%Y-%m-%d")
  end

  def self.current_month
    pbGetTimeNow.month
  end
end

module ClawMachineSystem
  def self.calculate_cost(trainer)
    data = trainer.minigames[:claw_machine] ||= {}
    streak = data[:streak] || 0
    base_cost = ClawMachineSettings::BASE_COST
    if ClawMachineTimeHelper.current_hour == ClawMachineSettings::DISCOUNT_HOUR
      base_cost = (base_cost * ClawMachineSettings::DISCOUNT_MULTIPLIER).ceil
    end
    streak_discount = (streak / ClawMachineSettings::STREAK_DISCOUNT_INTERVAL) * ClawMachineSettings::STREAK_COST_REDUCTION
    cost = base_cost - streak_discount
    cost = ClawMachineSettings::MINIMUM_COST if cost < ClawMachineSettings::MINIMUM_COST
    return cost # || base_cost
  end

  def self.determine_type_themes(day_seed)
    # Returns two distinct types based on day_seed ensuring no dependency between them
    all_types ||= []
    GameData::Type.each { |t| all_types.push(t) }
    srand day_seed
    type1 = all_types.sample
    type2 = all_types.sample while type2 == type1
    srand # Reset seed to default
    return type1, type2
  end

  def self.calculate_reward_tier(base_stat, is_shiny)
    base_score = base_stat + (is_shiny ? 50 : 0)
    ClawMachineSettings::REWARD_TIER_THRESHOLDS.each do |tier, range|
      return tier if range.include?(base_score)
    end
  end

  def self.tier_up_chance(is_shiny)
    return 0 unless is_shiny
    roll = rand(100)
    return 2 if roll < ClawMachineSettings::SHINY_TIER_UP_CHANCE_2
    return 1 if roll < ClawMachineSettings::SHINY_TIER_UP_CHANCE_1
  end

  def self.select_reward(category, tier, is_shiny)
    base_items = BASE_REWARD_TABLE[category][tier]
    base_pkmns = BASE_POKEMON_REWARDS[category]
    seasonal = seasonal_items(category)
    combined = (base_items + seasonal).uniq
    combined = (combined + base_pkmns).uniq if (rand(2) == 0)
    puts "[ClawMachineLog] Reward Pool: #{combined.inspect}"
    reward = combined.sample
    puts "[ClawMachineLog] Chosen Reward: #{reward}"
    # Determine if reward pokemon instead of item (simplified example)
    reward_is_pokemon = BASE_POKEMON_REWARDS[category].include?(reward)
    shiny_chance = is_shiny ? 0.05 : 0.01
    shiny_reward = reward_is_pokemon && rand < shiny_chance
    { reward: reward, shiny: shiny_reward }
  end

  def self.increment_streak(trainer)
    trainer.minigames ||= {}
    trainer.minigames[:claw_machine] ||= {}
    cm_data = trainer.minigames[:claw_machine]
    today = ClawMachineTimeHelper.current_date_string
    last_played = cm_data[:last_played]
    cm_data[:streak] ||= 0

    if last_played != today
      cm_data[:streak] += 1
      cm_data[:last_played] = today
      puts "[ClawMachineLog] Streak: Increased by 1. Now at #{cm_data[:streak]}"
    end
  end

  def self.log_attempt(trainer, mon, category:, base_stat_total:, type_matches:, rarity_score:, tier:, reward:, cost:, is_shiny:, seasonal_items:, seasonal_pokemon:)
    log =  "[ClawMachineLog] Player: #{trainer.public_ID}\n"
    log << "[ClawMachineLog] Pokémon: #{mon.name} (Shiny: #{is_shiny})\n"
    log << "[ClawMachineLog] Base Stat Total: #{base_stat_total}, Type Matches: #{type_matches}\n"
    log << "[ClawMachineLog] Rarity Score: #{rarity_score}, Reward Tier: #{tier}\n"
    log << "[ClawMachineLog] Reward: #{reward.inspect}\n"
    log << "[ClawMachineLog] Cost: #{cost} coins\n"
    log << "[ClawMachineLog] Category: #{category}\n"
    log << "[ClawMachineLog] ----------------------------------------\n"
    puts log
  end

  def self.perform_claw_pull(trainer, mon)
    data = trainer.minigames[:claw_machine] ||= {}
    cost = calculate_cost(trainer)
    return { success: false, error: "Not enough coins" } if ($player.coins < cost)

    base_stat_total = mon.baseStats.values.sum
    is_shiny = mon.shiny?
    day_seed = ClawMachineTimeHelper.current_date_string.hash

    type1, type2 = determine_type_themes(day_seed)

    mon_types ||= []
    mon.types.each { |t| mon_types.push(t) }
    type_matches = 0
    type_matches += 1 if mon_types.include?(type1)
    type_matches += 1 if mon_types.include?(type2)
    if mon_types.size == 2 && type_matches == 2
      type_matches += 1 # Extra bonus for matching both types
    end

    rarity_score = base_stat_total * (1 + ClawMachineSettings::TYPE_BONUS_PER_MATCH * type_matches) + (is_shiny ? 50 : 0)

    tier = calculate_reward_tier(rarity_score, is_shiny)
    # Apply shiny tier ups
    tier += tier_up_chance(is_shiny)

    # Clamp tier to max 4
    tier = 4 if tier > 4

    # Determine category from typing for reward pool selection
    category = TIERS.sample

    seasonal_items_pool = seasonal_items(category)
    seasonal_pokemon_pool = seasonal_pokemon(category)

    reward_info = select_reward(category, tier, is_shiny)

    $player.coins -= cost
    increment_streak(trainer)
    trainer.minigames[:claw_machine] = data

    log_attempt(trainer, mon,
                category: category,
                base_stat_total: base_stat_total,
                type_matches: type_matches,
                rarity_score: rarity_score,
                tier: tier,
                reward: reward_info[:reward],
                cost: cost,
                is_shiny: is_shiny,
                seasonal_items: seasonal_items_pool,
                seasonal_pokemon: seasonal_pokemon_pool
              )



    if GameData::Item.exists?(reward_info[:reward])
      $bag.add(reward_info[:reward], 1)
      pbMessage(_INTL("Your #{mon.name} found you a #{reward_info[:reward].inspect}."))
    end

    return { success: true, reward: reward_info[:reward], shiny_reward: reward_info[:shiny], cost: cost }
  end
end
