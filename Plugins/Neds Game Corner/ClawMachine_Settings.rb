
module ClawMachineSettings

  BASE_COST = 200 # Default: 200, Cost in coins to use the pkmn grabber.
  DISCOUNT_HOUR = 18 # Default: 18 (6PM), the time of day, in 24hr, that Discount hr starts.
  DISCOUNT_MULTIPLIER = 0.5 # Default 0.5 (50%), the discount applies during dicount hour.
  STREAK_DISCOUNT_INTERVAL = 5 # Default: 5
  STREAK_COST_REDUCTION = 20 # Default: 20, every [STREAK_DISCOUNT_INTERVAL] days of streak, reduce cost by 20 (capped)
  MINIMUM_COST = 50 # Default: 50

  # Reward chances and thresholds
  SUCCESS_BASE_CHANCE = 0.5 # Default: 0.5 (50%)
  SUCCESS_MAX_CHANCE = 1.0 # Default: 1.0 (100%)
  SUCCESS_MIN_CHANCE = 0.3 # Default: 0.3 (30%)

  DROP_CHANCE_MAX = 0.4 # Default: 0.4
  DROP_CHANCE_MIN = 0.05 # Default: 0.05

  SHINY_TIER_UP_CHANCE_1 = 60 # Default: 60, percent chance to tier up once
  SHINY_TIER_UP_CHANCE_2 = 20 # Default: 20, percent chance to tier up once, again

  # Reward tiers rarity score thresholds
  REWARD_TIER_THRESHOLDS = {
    1 => 0...250,
    2 => 250...400,
    3 => 400...500,
    4 => 500..Float::INFINITY
  }

  TYPE_BONUS_PER_MATCH = 0.1 # Default: 0.1
  RARITY_SCORE_TYPE_BONUS = 0.05 # Default: 0.05

end
