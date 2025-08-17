
GUILD_LEVEL_REQUIREMENTS = [
  0, 100, 150, 200, 250,
  300, 400, 500, 600, 700,
  800, 1000, 1200, 1400,
  1600, 1900, 2200,
  2500, 3000, 3500, 4000, 4500,
  5000, 10000, 15000, 20000, 25000,
  50000, 100000, 150000, 200000, 250000
]

def guild_increase_xp
    old_xp = $player.guild_data[:xp]
    new_xp = old_xp + 1
    @xp_bitmap.clear if @xp_bitmap
    old_level = $player.guild_data[:level] || 1
    new_level = old_level
    if new_xp >= GUILD_LEVEL_REQUIREMENTS[old_level]
      new_level += 1
      new_xp = 0
      @lvl_bitmap.clear if @lvl_bitmap
    end
    $player.set_guild_data(:xp, new_xp)
    $player.set_guild_data(:level, new_level)
end

class AdventureLogScene
  def pbUpdate
    @sprites["bg"].setBitmap("Graphics/UI/Backgrounds/" + Settings::MENU_BGSTYLES[$PokemonSystem.get_bg_style])
    @update += 1
    if (@update >= 3)
      @update -= 3
      @sprites["bg"].ox = 0 if @sprites["bg"].ox == -42 && @sprites["bg"].visible == true
      @sprites["bg"].oy = 0 if @sprites["bg"].ox == -48 && @sprites["bg"].visible == true
      @sprites["bg"].ox -= 1 if @sprites["bg"].visible == true
      @sprites["bg"].oy -= 1 if @sprites["bg"].visible == true
    end
    updateViewing
    gs_drawText($player.guild_data[:xp].to_s + " / " + GUILD_LEVEL_REQUIREMENTS[$player.guild_data[:level]].to_s, 128, 310, @xp_bitmap)
    gs_drawText($player.guild_data[:level].to_s, 112, 348, @lvl_bitmap)
    pbUpdateSpriteHash(@sprites)
  end

  def updateViewing
    xp = $player.guild_data[:xp]
    lvl = $player.guild_data[:level]
    lvl_req = GUILD_LEVEL_REQUIREMENTS[lvl]
    # INCREASES GUILD XP BY 1, FOR DEBUGGING
    guild_increase_xp
    # INPUT TRACKING
    dorefresh_page = false
    dorefresh_desc = false
    if Input.trigger?(Input::RIGHT)
      @page += 1
      @page = 0 if @page > 2
      dorefresh_page = true
      dorefresh_desc = true
    elsif Input.trigger?(Input::LEFT)
      @page -= 1
      @page = 2 if @page < 0
      dorefresh_page = true
      dorefresh_desc = true
    elsif Input.trigger?(Input::UP)
      @selected -= 1
      @selected = 0 if @selected < 0
      dorefresh_desc = true
    elsif Input.trigger?(Input::DOWN)
      @selected += 1
      if @selected > 3
        @selected = 3
      end
      dorefresh_desc = true
    end
    @desc_bitmap.clear if (@desc_bitmap && dorefresh_desc)
    @sprites["hand"].y = 44 + (@selected * 72)
    # GUILD XP UPDATING
    w = xp * 154 / lvl_req
    w = ((w / 2).round) * 2
    @xpBar.src_rect.width = w
    # UPDATING QUEST VISIBILITY
    (0..2).each do |n|
      @sprites["log_#{n}"].visible = @displaying[n]
    end
    # UPDATING LEAF ICON


    # DISPLAY QUEST DESCRIPTION BASED ON SELECTED
    if (@activeQuests.length == 2)
      @displaying = [true, true, false]
    elsif (@activeQuests.length == 1)
      @displaying = [true, false, false]
    elsif (@activeQuests.length == 0)
      @displaying = [false, false, false]
    end
    if (@activeQuests.length >= 3)
      @displaying = [true, true, false]
    end
    if (@activeQuests[@selected].is_a?(Symbol) && @page = 0)
      desc = $quest_data.getQuestDescription(@activeQuests[@selected])
      gs_drawText(desc, 320, 56, @desc_bitmap, width = 99999)
    end
    @selected = 0 if dorefresh_page
    drawPage(@page) if dorefresh_page
  end

  def pbStartScene()
    @update = 0
    @page = 0
    @selected = 0
    @activeQuests = []
    @displaying = [true, true, true]
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "Summary/bg", @viewport)
    @sprites["bg"].z = -99999

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["xp_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["lvl_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["desc_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlay = @sprites["overlay"].bitmap
    @xp_bitmap = @sprites["xp_overlay"].bitmap
    @lvl_bitmap = @sprites["lvl_overlay"].bitmap
    @desc_bitmap = @sprites["desc_overlay"].bitmap
    pbSetSystemFont(@overlay)

    @sprites["overlay"].z = 5

    (0..2).each do |n|
      @sprites["log_#{n}"] = IconSprite.new(4, 74 + (n * 72), @viewport)
      @sprites["log_#{n}"].setBitmap("Graphics/UI/Adventure Log/log_box")
      @sprites["log_#{n}"].visible = false
    end
    @sprites["log_info"] = IconSprite.new(308, 52, @viewport)
    @sprites["log_info"].setBitmap("Graphics/UI/Adventure Log/log_info")

    @sprites["log_guild_xp_bar"] = IconSprite.new(0, 302, @viewport)
    @sprites["log_guild_xp_bar"].setBitmap("Graphics/UI/Adventure Log/log_guild_xp_bar")
    @xpBarBitmap  = AnimatedBitmap.new("Graphics/UI/Adventure Log/guild_xp")
    @xpBar = Sprite.new(@viewport)
    @xpBar.bitmap = @xpBarBitmap.bitmap
    @sprites["xpBar"] = @xpBar
    @sprites["xpBar"].x = 88
    @sprites["xpBar"].y = 340

    @sprites["page"] = IconSprite.new(0, 0, @viewport)
    @sprites["page"].z = -5

    @sprites["hand"] = IconSprite.new(0, 44, @viewport)
    @sprites["hand"].setBitmap("Graphics/UI/Adventure Log/hand")
    @sprites["hand"].z = 1

    @sprites["leaf"] = IconSprite.new(36, 328, @viewport)
    @sprites["leaf"].z = 2

    gs_drawText("Story", 88, 0, @overlay)

    drawPage(@page)
  end

  def drawPage(page)
    @sprites["page"].setBitmap("Graphics/UI/Adventure Log/page_#{page}")
    case page
    when 0
      @activeQuests = PokemonGlobalMetadata.getActiveQuests



    when 1

    when 2

    end
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
      pbUpdate
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end # end of class

class AdventureLog_Screen
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

def show_adventure_log
  pbFadeOutIn {
    scene = AdventureLogScene.new
    screen = AdventureLog_Screen.new(scene)
    screen.pbStartScreen
  }
end
