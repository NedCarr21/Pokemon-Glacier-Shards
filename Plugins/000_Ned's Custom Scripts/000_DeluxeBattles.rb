def gsDeluxeRotom
  setBattleRule("cannotRun")
  setBattleRule("disablePokeBalls")
  setBattleRule("terrain", :Electric)
  setBattleRule("alwaysCapture")
  setBattleRule("battleBGM", "Battle roaming")
  setBattleRule("battleIntroText", "The Rotom attacked!")
  setBattleRule("editWildPokemon", {
    :obtain_text => "The Television.",
    :hp_level    => 1.5,
    :immunities  => [:OHKO, :ESCAPE, :INDIRECT]
})
setBattleRule("midbattleScript", {

"RoundStartCommand_1_foe" => {
  "battlerHPCap" => -1,
},

"RoundEnd_foe_repeat" => {
  "playSE"        => "Anim/Sound2",
  "battlerForm"   => [:Cycle, "{1} jumped into an appliance."],
  "playCry"       => :Self,
  "battlerMoves"  => :Reset,
  "ignoreAfter"   => "TargetHPLow_foe",
  "battlerStatus" => [:NONE, true],
  "battlerHP"     => [4, "{1} regenerated some HP!"]
},

"TargetTookDamage_foe_repeat" => {
  "ignoreAfter" => "TargetHPLow_foe",
  "text"        => "{1} started to regenerate!",
  "battlerHP"   => [8, "{1} regenerated some HP!"]
},

"TargetHPLow_foe" => {
  "text"          => "{1} has become too weak to regenerate any more HP!",
  "playSE"        => "Anim/Sound2",
  "battlerForm"   => [0, "{1} reverted back."],
  "playCry"       => :Self,
  "battlerMoves"  => :Reset,
},

"BattlerReachedHPCap_foe" => {
  "speech"       => [:Opposing, "It's getting weak!", "Go, Poké Ball!"],
  "disableBalls" => false,
  "useItem"      => :POKEBALL
}

})
gsShinyStatic(:ROTOM,12,10)

end

def gsDeluxePalossand
  setBattleRule("cannotRun")
  setBattleRule("disablePokeBalls")
  setBattleRule("battleBGM", "Battle roaming")
  setBattleRule("battleIntroText", "The Palossand attacked!")
  setBattleRule("editWildPokemon", {
    :hp_level    => 2,
    :immunities  => [:OHKO, :ESCAPE, :INDIRECT]
})
end

def gsDeluxeCrobat
  setBattleRule("cannotRun")
  setBattleRule("disablePokeBalls")
  setBattleRule("battleBGM", "Battle roaming")
  setBattleRule("battleIntroText", "The Crobat attacked!")
  setBattleRule("editWildPokemon", {
    :hp_level    => 2,
    :immunities  => [:OHKO, :ESCAPE, :INDIRECT]
})
end

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#--------------------------------TRAINER-BATTLES--------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

def gsDeluxeTheo_1
  setBattleRule("midbattleScript", {

    "RoundStartCommand_1_foe" => {
      "speech"      => "Me and my {1} won't lose to you!",
      "battlerStats" => [:SPEED, 2]
    },

    "RoundStartCommand_1" => {
      "battlerStatus" => :BURN
    },

    "AfterLastSwitchIn_foe" => {
      "speech" => "Go {1}, burn them now!",
      "battlerStats" => [:SPEED, 2]
    },

    "AfterLastSwitchIn" => {
      "battlerStatus" => :BURN
    }

  })
end
