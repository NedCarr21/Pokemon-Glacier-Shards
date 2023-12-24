MenuHandlers.add(:pause_menu, :quests, {
  "name"      =>  _INTL("Quests"),
  "order"     => 50,
  "condition" => proc { next hasAnyQuests? && !$player.has_poke_nav },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = QuestList_Scene.new
      screen = QuestList_Screen.new(scene)
      screen.pbStartScreen
      menu.pbRefresh
    }
    next false
  }
})

MenuHandlers.add(:pause_menu, :pokenav, {
  "name"      => _INTL("PokéNav"),
  "order"     => 8,
  "condition" => proc { next $player.has_poke_nav },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    menu.pbHideMenu
      pbFadeOutIn {
        scene = PokeNav_Scene.new
        screen = PokeNav_Screen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    next true
  }
})

MenuHandlers.add(:debug_menu, :randomizer_on, {
  "name"        => _INTL("Turn on Randomizer"),
  "parent"      => :battle_menu,
  "description" => _INTL("Toggles the randomizer on."),
  "effect"      => proc {
    $game_switches[61] = true;
    pbMessage(_INTL("Randomizer is now on."))
  }
})

MenuHandlers.add(:debug_menu, :randomizer_off, {
  "name"        => _INTL("Turn off Randomizer"),
  "parent"      => :battle_menu,
  "description" => _INTL("Toggles the randomizer off."),
  "effect"      => proc {
    $game_switches[61] = false;
    pbMessage(_INTL("Randomizer is now off."))
  }
})

MenuHandlers.add(:debug_menu, :play_mining_game, {
  "name"        => _INTL("Mining Minigame"),
  "parent"      => :field_menu,
  "description" => _INTL("Starts a mining minigame."),
  "effect"      => proc {
    pbMiningGame
  }
})

MenuHandlers.add(:debug_menu, :play_mining_game, {
  "name"        => _INTL("Mining Minigame"),
  "parent"      => :field_menu,
  "description" => _INTL("Starts a mining minigame."),
  "effect"      => proc {

  }
})
