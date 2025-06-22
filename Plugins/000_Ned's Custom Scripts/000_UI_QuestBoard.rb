




#------- QUEST LIMITS ---------
#
# The limits for each type of quest, the max amount a quest can ask a player to collect/defeat/battle.
# Do not set any of these values to 0 or below, this will definitely break how things function.
#
QB_TYPE_LIMIT = 15 # max # of pokemon a quest can request a player to defeat for type quests.
QB_ITEM_LIMIT = 20 # max # of items a quest can request a player to collect.
QB_CAPTURE_LIMIT = 3 #max # of pokemon a quest can request a player to catch.
QB_TRAINER_LIMIT = 3 # max # of trainers a quest can request a player to defeat.

QB_RARE_CHANCE = 10 # % chance to get a rare quest, 0 to disable rare quests.

QB_ITEMS = [
  :ORANBERRY, :SITRUSBERRY, :LUMBERRY,
]



EventHandlers.add(:on_wild_battle_end, :quest_board_counter,
  proc { |species, level, decision|
    if (decision == 4) # 4: wild pokemon was caught.

    end
  }
)


#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------

class QuestBoardScene

  update_count = 0

  def pbUpdate
    update_count++
    # check if new refresh to register new quests, and display cooldown until next refresh
    if (update_count >= 600) # every 600 updates/frames
      update_count -= 600
    end

    # animate background

    pbUpdateSpriteHash(@sprites)
  end


  def pbStartScene()
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "Summary/bg", @viewport)
    @sprites["bg"].z = -99999

    @sprites["q1_quest"] = IconSprite.new(0, 0, @viewport)
    @sprites["q1_quest"].setBitmap("Graphics/Pictures/UI/QuestBoard/quest_box")
    @sprites["q1_quest"].x = 17
    @sprites["q1_quest"].y = 22
    @sprites["q1_quest"].z = 1

  end

end

#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------

def generateQuest(name = "", quest_type = "", count = 0, total = 1, collecting = :POTION, rare = false)
  if (QB_RARE_CHANCE > 0)
    rare = (rand(QB_RARE_CHANCE) == 0)
  end

  if (quest_type == "")
    case rand(11)
      when 0..2
        quest_type = "item_obtain"
      when 3..5
        quest_type = "pkmn_catch"
      when 6..9
        quest_type = "pkmn_defeat"
      when 10
        quest_type = "trainer_defeat"
    end # end of case
  end # end of if (quest_type == "")

  if (quest_type == "pkmn_catch")
    collecting = generateQuestPkmn



  end
  return ([name, quest_type, count, total, collecting, rare])
end

def generateQuestItem
  pkmn = []

  $PokemonGlobal.visitedMaps.each do |m|
    map_ID = $PokemonGlobal.visitedMaps[m]
      pkmn.push(choose_wild_pokemon_for_map(map_ID, enc_type))

  end




  return pkmn
end

def generateQuestPkmn




end
