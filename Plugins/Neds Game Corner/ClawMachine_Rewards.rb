
TIERS = [:TECH,:HEAVY,:TRICK,:NATURE,:UTILITY]

BASE_POKEMON_REWARDS = {
  :TECH => [:PORYGON, :MAGNEMITE],
  :HEAVY => [:GOLETT, :ARON, :WAILMER],
  :TRICK => [:ZORUA, :MRMIME, :GIMMIGHOUL],
  :NATURE => [:TANGELA, :SHROOMISH],
  :UTILITY => [:DITTO, :ROTOM]
}

BASE_REWARD_TABLE = {
  :TECH => {
    1 => [:DIREHIT, :ETHER, :ELIXER, :MAGNET],
    2 => [:THUNDERSTONE, :CELLBATTERY, :ELECTRICGEM],
    3 => [:UPGRADE, :EVIOLITE, :DUBIOUSDISK, :METALCOAT],
    4 => [:TERRAINEXTENDER, :ELECTIRIZER, :ELECTRICSEED]
  },
  :HEAVY => {
    1 => [:HYPERPOTION, :IRON],
    2 => [:PROTEIN, :IRON, :IRONBALL],
    3 => [:CHOICEBAND, :LEFTOVERS],
    4 => [:ASSAULTVEST, :POWERBRACER]
  },
  :TRICK => {
    1 => [:MAXREPEL],
    2 => [:SMOKEBALL, :AIRBALLOON],
    3 => [:FOCUSSASH, :WIDELENS],
    4 => [:BRIGHTPOWDER, :KINGSROCK]
  },
  :NATURE => {
    1 => [:HEALPOWDER, :BERRYJUICE],
    2 => [:LEAFSTONE, :BIGROOT],
    3 => [:BIGMUSHROOM, :SITRUSBERRY],
    4 => [:GRASSYSEED, :TERRAINEXTENDER]
  },
  :UTILITY => {
    1 => [:ESCAPEROPE],
    2 => [:SMOKEBALL, :SCOPELENS],
    3 => [:CHOICESCARF, :QUICKCLAW],
    4 => [:ABILITYCAPSULE, :LOVELYMINT]
  }
}

SEASONAL_REWARD_ITEMS = {
  1 => { :NATURE => [:ICICLE_PLATE, :SNOWBALL] },
  2 => { :UTILITY => [:LOVE_BALL, :HEART_SCALE] },
  3 => { :NATURE => [:MIRACLE_SEED, :MEADOW_PLATE] },
  4 => { :TRICK => [:TRICK_ROOM, :FOCUS_BAND] },
  5 => { :NATURE => [:HONEY, :FLOWER_MAIL] },
  6 => { :TECH => [:SUN_STONE, :SHINY_STONE] },
  7 => { :HEAVY => [:FIRE_STONE, :FLAME_ORB] },
  8 => { :UTILITY => [:LUXURY_BALL, :SHELL_BELL] },
  9 => { :TRICK => [:RAZOR_CLAW, :RAZOR_FANG] },
 10 => { :TRICK => [:SPELL_TAG, :BLACK_GLASSES] },
 11 => { :TECH => [:METAL_COAT, :IRON_BALL] },
 12 => { :NATURE => [:SNOWBALL, :CHILLING_BAND] }
}

SEASONAL_REWARD_POKEMON = {
  1 => { :NATURE => [:SNOVER, :CUBCHOO] },
  2 => { :UTILITY => [:LUVDISC, :ALOMOMOLA] },
  3 => { :NATURE => [:BUNEARY, :FLABEBE] },
  4 => { :TRICK => [:AUDINO, :TOGEDEMARU] },
  5 => { :NATURE => [:COMFEE, :CHERUBI] },
  6 => { :TECH => [:ROTOM, :BLITZLE] },
  7 => { :HEAVY => [:MAGMAR, :TORKOAL] },
  8 => { :UTILITY => [:CHANSEY, :BLISSEY] },
  9 => { :TRICK => [:SNEASEL, :GLIGAR] },
 10 => { :TRICK => [:PHANTUMP, :PUMPKABOO] },
 11 => { :TECH => [:KLINK, :MAGNEMITE] },
 12 => { :NATURE => [:SNORUNT, :DELIBIRD] }
}

def seasonal_items(category)
  month = ClawMachineTimeHelper.current_month
  items = (SEASONAL_REWARD_ITEMS[month] && SEASONAL_REWARD_ITEMS[month][category]) || []
  puts "[ClawMachineLog] Seasonal Items (#{category}, Month #{pbGetMonthName(month)}): #{items.inspect}"
  return items
end

def seasonal_pokemon(category)
  month = ClawMachineTimeHelper.current_month
  pokemon = (SEASONAL_REWARD_POKEMON[month] && SEASONAL_REWARD_POKEMON[month][category]) || []
  puts "[ClawMachineLog] Seasonal Pokémon (#{category}, Month #{pbGetMonthName(month)}): #{pokemon.inspect}"
  return pokemon
end
