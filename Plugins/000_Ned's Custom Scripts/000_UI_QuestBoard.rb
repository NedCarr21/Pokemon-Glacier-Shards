




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

EASILY_ONTAINABLE_ITEMS = [:ORANBERRY,:SITRUSBERRY,:POTION,:POKEBALL,:REPEL,:ANTIDOTE,:PARALYZEHEAL,:AWAKENING,:BURNHEAL,:ICEHEAL,:BASICBAIT]

EventHandlers.add(:on_wild_battle_end, :quest_board_counter,
  proc { |species, level, decision|
    if (decision == 4) # 4: wild pokemon was caught.

    end
  }
)


#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------

QBUI_X = 34
QBUI_Y = 44

class QuestBoardScene

  @qb_update = 0

  def pbUpdate
    # animate background
    @qb_update += 1
    if (@qb_update >= 3)
      @qb_update -= 3
      @sprites["bg"].ox = 0 if @sprites["bg"].ox == -42 && @sprites["bg"].visible == true
      @sprites["bg"].oy = 0 if @sprites["bg"].ox == -48 && @sprites["bg"].visible == true
      @sprites["bg"].ox -= 1 if @sprites["bg"].visible == true
      @sprites["bg"].oy -= 1 if @sprites["bg"].visible == true
    end
    qbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene()
    @qb_update = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @numbersBitmap = AnimatedBitmap.new("Graphics/UI/QuestBoard/numbers")

    @nums = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @nums.z = 5
    pbSetSystemFont(@nums.bitmap)
    @sprites = {}

    addBackgroundPlane(@sprites, "bg", "Summary/bg", @viewport)
    @sprites["bg"].z = -99999
    @sprites["nums"] = @nums
    @sprites["nums"].z = 2

    @qb_selected = 1

    @sprites["back"] = IconSprite.new(QBUI_X + 360, QBUI_Y + (3 * 96), @viewport)
    @sprites["back"].setBitmap("Graphics/UI/QuestBoard/back_button")
    @sprites["back"].z = 1

    (0..2).each do |n|
      @sprites["q#{n}_quest"] = IconSprite.new(QBUI_X, QBUI_Y + (n * 96), @viewport)
      @sprites["q#{n}_quest"].setBitmap("Graphics/UI/QuestBoard/quest_box")
      @sprites["q#{n}_quest"].z = 1

      @sprites["q#{n}_quest_reward"] = IconSprite.new(QBUI_X + 360, QBUI_Y + (n * 96), @viewport)
      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward")
      @sprites["q#{n}_quest_reward"].z = 1
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def qbUpdate
    nums_dir = _INTL("Graphics/UI/QuestBoard/numbers")
    imagepos = []
    @nums.bitmap.clear

    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)

    textpos = [
      [$player.qb_quests[0][0], 130, 54, :left, base, shadow],
      [$player.qb_quests[1][0], 130, 150, :left, base, shadow],
      [$player.qb_quests[2][0], 130, 246, :left, base, shadow]
    ]
    pbDrawTextPositions(@nums.bitmap, textpos)

    (0..2).each do |n|
      index = 0
      index_rew = 0
      type = 1
      type = 3 if $player.qb_quests[n][5] # is rare quest
      type = 2 if complete?($player.qb_quests[n])

      q_progress = $player.qb_quests[n][2].to_s.split('').map(&:to_i)
      q_progress.each do |p|
        imagepos.push([nums_dir, QBUI_X+96+16*index, QBUI_Y+46+(n*96), p*16, type*16, 16, 16])
        index += 1
      end
      imagepos.push([nums_dir, QBUI_X+96+16*index, QBUI_Y+46+(n*96), 10*16, type*16, 16, 16])
      index += 1
      q_total = $player.qb_quests[n][3].to_s.split('').map(&:to_i)
      q_total.each do |t|
        imagepos.push([nums_dir, QBUI_X+96+16*index, QBUI_Y+46+(n*96), t*16, type*16, 16, 16])
        index += 1
      end
      q_points = $player.qb_quests[n][6].to_s.split('').map(&:to_i)
      bump = 0
      bump = 8 if (q_points.length != 1)
      q_points.each do |p|
        imagepos.push([nums_dir, QBUI_X+394+16*index_rew-bump, QBUI_Y+66+(n*96), p*16, type*16, 16, 16])
        index_rew += 1
      end

      points = $player.qb_quests[3].to_s.split('').map(&:to_i)
      points.each_with_index do |p, index|
        imagepos.push([nums_dir, 60 + index*16, 360, p*16, 16, 16, 16])
      end

      pbDrawImagePositions(@nums.bitmap, imagepos)

      # update item_obtain quests count number from bag quantity of item
      if ($player.qb_quests[n][1] == "item_obtain")
        $player.qb_quests[n][2] = [$bag.quantity($player.qb_quests[n][4]), $player.qb_quests[n][3]].min
      end

      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward")
      @sprites["back"].setBitmap("Graphics/UI/QuestBoard/back_button")
      @sprites["q#{n}_quest"].setBitmap("Graphics/UI/QuestBoard/quest_box")

      @sprites["back"].setBitmap("Graphics/UI/QuestBoard/back_button_select") if (@qb_selected == 4)
      @sprites["q#{n}_quest"].setBitmap("Graphics/UI/QuestBoard/quest_box_rare") if ($player.qb_quests[n][5])
      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward_select") if (@qb_selected == n+1)

      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward_rare") if ($player.qb_quests[n][5])
      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward_rare_select") if (@qb_selected == n+1 && $player.qb_quests[n][5])
      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward_rare_complete") if ($player.qb_quests[n][5] && complete?($player.qb_quests[n]))
      @sprites["q#{n}_quest_reward"].setBitmap("Graphics/UI/QuestBoard/quest_box_reward_rare_complete_select") if (@qb_selected == n+1 && $player.qb_quests[n][5] && complete?($player.qb_quests[n]))

    end # end of do |n|
  end # end of def qbUpdate

  def complete?(quest)
    return (quest[2] >= quest[3])
  end

  def claim_and_reset(quest_num)
    qty = $player.qb_quests[quest_num][6] # amount of points to give as reward
    $player.qb_quests[3] += qty
    $player.qb_quests[quest_num] = generateQuest
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
      if(Input.trigger?(Input::ACTION) || Input.trigger?(Input::USE))
        if (@qb_selected == 4) # back button
          pbPlayCloseMenuSE
          break
        elsif (@qb_selected == 1 && complete?($player.qb_quests[0]))
          claim_and_reset(0)
        elsif (@qb_selected == 2 && complete?($player.qb_quests[1]))
          claim_and_reset(1)
        elsif (@qb_selected == 3 && complete?($player.qb_quests[2]))
          claim_and_reset(2)
        end
      elsif Input.trigger?(Input::UP)
        @qb_selected -= 1
        @qb_selected = 4 if @qb_selected < 1
      elsif Input.trigger?(Input::DOWN)
        @qb_selected += 1
        @qb_selected = 1 if @qb_selected > 4
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @numbersBitmap.dispose
    @viewport.dispose
  end

end

class QuestBoard_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen()
    @scene.pbStartScene()
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end
end
#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
def generateQuest(name = "", quest_type = "", count = 0, total = 1, collecting = :POTION, rare = false, points = 1)
  arr = [name, quest_type, count, total, collecting, rare, points]
  if (QB_RARE_CHANCE > 0)
    arr[5] = (rand(QB_RARE_CHANCE) == 0)
  end

  if (arr[1] == "")
    case rand(0..10)
      when 0..2
        arr[1] = "item_obtain" # obtain # of specific item
      when 3..5
        arr[1] = "pkmn_catch" # catch # of specific pkmn
      when 6..9
        arr[1] = "pkmn_defeat" # defeat # of type of pkmn
      when 10
        arr[1] = "trainer_defeat" # defeat # of trainers
    end # end of case
  end # end of if (quest_type == "")

  if (arr[1] == "item_obtain")
    Kernel.echo("Quest Board: Generating Quest Item...\n")
    arr[4] = generateQuestItem
    arr[3] = rand(1..5)
    arr[0] = ("Obtain: " + arr[4].to_s)

  elsif (arr[1] == "pkmn_catch")
    Kernel.echo("Quest Board: Generating Quest Pokemon...\n")
    arr[4] = generateQuestPkmn
    arr[3] = rand(2..5)*2
    arr[6] *= 2
    arr[0] = ("Catch: " + arr[4].to_s)

  elsif (arr[1] == "pkmn_defeat")
    Kernel.echo("Quest Board: Generating Quest Type...\n")
    arr[4] = generateQuestType
    arr[3] = rand(1..4)*5
    arr[0] = ("Defeat: " + arr[4].to_s + " Types!")

  elsif (arr[1] == "trainer_defeat")
    Kernel.echo("Quest Board: Generating Quest Trainer...\n")
    arr[3] = rand(1..3)
    arr[6] *= 3
    arr[0] = ("Defeat Trainers!")

  else
    Kernel.echo("Quest Board: [ERROR] Quest Type: N/A\n")
  end

  arr[3] = (total*rand(2..3)).floor if arr[5]
  arr[6] += (arr[3]/2.floor)

  Kernel.echo("Quest: " + arr.to_s + "\n")

  return arr
end

def generateQuestItem
  return ((EASILY_ONTAINABLE_ITEMS).uniq).sample
end

def generateQuestPkmn
  pkmn = [[:BULBASAUR, 5]]
  $PokemonGlobal.visitedMaps.each do |key, value|
    GameData::EncounterType.each do |enc_type|
      if (value)
        pkmn.push($PokemonEncounters.choose_wild_pokemon_for_map(key, enc_type.type))
      end
    end
  end

  p = pkmn.sample[0]
  while ($player.pokedex.seen?(p))
    p = pkmn.sample[0]
  end
  return p
end

def generateQuestType
  type = []
  GameData::Type.each do |t|
    type.push(t)
  end
  return type.sample.id
end

#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------
def qb_showBoard
  pbFadeOutIn {
    scene = QuestBoardScene.new
    screen = QuestBoard_Screen.new(scene)
    screen.pbStartScreen
  }
end

EventHandlers.add(:on_frame_update, :reset_quests,
  proc {
    if ($player && $game_player && $game_switches[68])
      time = pbGetTimeNow
      if ((time.hour == 0 && time.min == 0) || $player.qb_quests == [])
        $player.reset_all_quests
        $player.qb_quests[3] = 0 # player's points
      end
    end
  }
)
