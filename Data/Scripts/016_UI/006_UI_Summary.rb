#===============================================================================
#
#===============================================================================
class MoveSelectionSprite < Sprite
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport = nil, fifthmove = false)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/UI/Summary/cursor_move")
    @frame = 0
    @index = 0
    @fifthmove = fifthmove
    @preselected = false
    @updating = false
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def preselected=(value)
    @preselected = value
    refresh
  end

  def refresh
    w = @movesel.width
    h = @movesel.height / 2
    self.x = 240
    self.y = 92 + (self.index * 64)
    self.y -= 76 if @fifthmove
    self.y += 20 if @fifthmove && self.index == Pokemon::MAX_MOVES   # Add a gap
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    @updating = true
    super
    @movesel.update
    @updating = false
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class RibbonSelectionSprite < MoveSelectionSprite
  def initialize(viewport = nil)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/UI/Summary/cursor_ribbon")
    @frame = 0
    @index = 0
    @preselected = false
    @updating = false
    @spriteVisible = true
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def refresh
    w = @movesel.width
    h = @movesel.height / 2
    self.x = -2 + ((self.index % 4) * 62)
    self.y = 54 + ((self.index / 4).floor * 62)
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    @updating = true
    super
    self.visible = @spriteVisible && @index >= 0 && @index < 16
    @movesel.update
    @updating = false
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSummary_Scene
  MARK_WIDTH  = 16
  MARK_HEIGHT = 16
  # Colors used for messages in this scene
  RED_TEXT_BASE     = Color.new(248, 56, 32)
  RED_TEXT_SHADOW   = Color.new(224, 152, 144)
  BLACK_TEXT_BASE   = Color.new(64, 64, 64)
  BLACK_TEXT_SHADOW = Color.new(176, 176, 176)



  def pbUpdate
    @summary_update += 1

    if (@summary_update >= 3)
      @summary_update -= 3
      @sprites["bg"].ox = 0 if @sprites["bg"].ox == -42 && @sprites["bg"].visible == true
      @sprites["bg"].oy = 0 if @sprites["bg"].ox == -50 && @sprites["bg"].visible == true
      @sprites["bg"].ox -= 1 if @sprites["bg"].visible == true
      @sprites["bg"].oy -= 1 if @sprites["bg"].visible == true
      pbUpdateSpriteHash(@sprites)
    end



  end

  def pbStartScene(party, partyindex, inbattle = false)
    @summary_update = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @inbattle   = inbattle
    @page = 1
    @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    @markingbitmap = AnimatedBitmap.new("Graphics/UI/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)

    @gswhite = Tone.new(255,255,255)
    @gsopacity = 180 # from 0 to 255

    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = 426
    @sprites["pokemon"].y = 214
    @sprites["pokemon"].z += 3
    @sprites["pokemon"].setPokemonBitmap(@pokemon)

    @sprites["pkmndown"] = PokemonSprite.new(@viewport)
    @sprites["pkmndown"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmndown"].x = @sprites["pokemon"].x
    @sprites["pkmndown"].y = @sprites["pokemon"].y - 2
    @sprites["pkmndown"].z = @sprites["pokemon"].z - 1
    @sprites["pkmndown"].tone = @gswhite
    @sprites["pkmndown"].opacity = @gsopacity
    @sprites["pkmndown"].setPokemonBitmap(@pokemon)

    @sprites["pkmnup"] = PokemonSprite.new(@viewport)
    @sprites["pkmnup"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmnup"].x = @sprites["pokemon"].x
    @sprites["pkmnup"].y = @sprites["pokemon"].y + 2
    @sprites["pkmnup"].z = @sprites["pokemon"].z - 1
    @sprites["pkmnup"].tone = @gswhite
    @sprites["pkmnup"].opacity = @gsopacity
    @sprites["pkmnup"].setPokemonBitmap(@pokemon)

    @sprites["pkmnright"] = PokemonSprite.new(@viewport)
    @sprites["pkmnright"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmnright"].x = @sprites["pokemon"].x + 2
    @sprites["pkmnright"].y = @sprites["pokemon"].y
    @sprites["pkmnright"].z = @sprites["pokemon"].z - 1
    @sprites["pkmnright"].tone = @gswhite
    @sprites["pkmnright"].opacity = @gsopacity
    @sprites["pkmnright"].setPokemonBitmap(@pokemon)

    @sprites["pkmnleft"] = PokemonSprite.new(@viewport)
    @sprites["pkmnleft"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmnleft"].x = @sprites["pokemon"].x - 2
    @sprites["pkmnleft"].y = @sprites["pokemon"].y
    @sprites["pkmnleft"].z = @sprites["pokemon"].z - 1
    @sprites["pkmnleft"].tone = @gswhite
    @sprites["pkmnleft"].opacity = @gsopacity
    @sprites["pkmnleft"].setPokemonBitmap(@pokemon)

    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 68
    @sprites["pokeicon"].visible = false

    @item_x = 292
    @item_y = 266

    @sprites["itemicon"] = ItemIconSprite.new(@item_x, @item_y, @pokemon.item_id, @viewport)
    @sprites["itemicon"].z += 1
    @sprites["itemicon"].blankzero = true

    @sprites["itemicondown"] = ItemIconSprite.new(@item_x, @item_y + 2, @pokemon.item_id, @viewport)
    @sprites["itemicondown"].tone = @gswhite
    @sprites["itemicondown"].opacity = @gsopacity
    @sprites["itemicondown"].blankzero = true
    @sprites["itemicondown"].z = @sprites["itemicon"].z - 1

    @sprites["itemiconup"] = ItemIconSprite.new(@item_x, @item_y - 2, @pokemon.item_id, @viewport)
    @sprites["itemiconup"].tone = @gswhite
    @sprites["itemiconup"].opacity = @gsopacity
    @sprites["itemiconup"].blankzero = true
    @sprites["itemiconup"].z = @sprites["itemicon"].z - 1

    @sprites["itemiconright"] = ItemIconSprite.new(@item_x + 2, @item_y, @pokemon.item_id, @viewport)
    @sprites["itemiconright"].tone = @gswhite
    @sprites["itemiconright"].opacity = @gsopacity
    @sprites["itemiconright"].blankzero = true
    @sprites["itemiconright"].z = @sprites["itemicon"].z - 1

    @sprites["itemiconleft"] = ItemIconSprite.new(@item_x - 2, @item_y, @pokemon.item_id, @viewport)
    @sprites["itemiconleft"].tone = @gswhite
    @sprites["itemiconleft"].opacity = @gsopacity
    @sprites["itemiconleft"].blankzero = true
    @sprites["itemiconleft"].z = @sprites["itemicon"].z - 1

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible     = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonpresel"].visible     = false
    @sprites["ribbonpresel"].preselected = true
    @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonsel"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/up_arrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 350
    @sprites["uparrow"].y = 56
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/down_arrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 350
    @sprites["downarrow"].y = 260
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
    @sprites["markingbg"].setBitmap("Graphics/UI/Summary/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
    @sprites["markingsel"].setBitmap("Graphics/UI/Summary/cursor_marking")
    @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
    @sprites["markingsel"].visible = false
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true

    addBackgroundPlane(@sprites, "bg", "Summary/bg", @viewport)
    @sprites["bg"].z = -9999

    pbBottomLeftLines(@sprites["messagebox"], 2)
    @nationalDexList = [:NONE]
    GameData::Species.each_species { |s| @nationalDexList.push(s.species) }
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party, partyindex, move_to_learn)
    @summary_update = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @page = 4
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport, !move_to_learn.nil?)
    @sprites["movesel"].visible = false
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0

    addBackgroundPlane(@sprites, "bg", "Summary/bg", @viewport)
    @sprites["bg"].z = -99999

    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    drawSelectedMove(new_move, @pokemon.moves[0])
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @markingbitmap&.dispose
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["messagebox"].text = text
    @sprites["messagebox"].visible = true
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      elsif Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        break
      end
    end
    @sprites["messagebox"].visible = false
  end

  def pbConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) do
      cmdwindow.z       = @viewport.z + 1
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        pbUpdate
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
            ret = (cmdwindow.index == 0)
            break
          end
        end
      end
    end
    @sprites["messagebox"].visible = false
    return ret
  end

  def pbShowCommands(commands, index = 0)
    ret = -1
    using(cmdwindow = Window_CommandPokemon.new(commands)) do
      cmdwindow.z = @viewport.z + 1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    end
    return ret
  end

  def drawMarkings(bitmap, x, y)
    mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
    markings = @pokemon.markings
    markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
    (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
      markrect.x = i * MARK_WIDTH
      markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
      bitmap.blt(x + (i * MARK_WIDTH), y, @markingbitmap.bitmap, markrect)
    end
  end

  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg
      return
    end
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pkmnup"].setPokemonBitmap(@pokemon)
    @sprites["pkmndown"].setPokemonBitmap(@pokemon)
    @sprites["pkmnleft"].setPokemonBitmap(@pokemon)
    @sprites["pkmnright"].setPokemonBitmap(@pokemon)

    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["itemicon"].item = @pokemon.item_id
    @sprites["itemiconup"].item = @pokemon.item_id
    @sprites["itemicondown"].item = @pokemon.item_id
    @sprites["itemiconleft"].item = @pokemon.item_id
    @sprites["itemiconright"].item = @pokemon.item_id

    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    # Set background image
    @sprites["background"].setBitmap("Graphics/UI/Summary/bg_#{page}")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/UI/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 480, 84])
    # Show status/fainted/Pokérus infected icon
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      imagepos.push([_INTL("Graphics/UI/statuses"), 338, 280, 0, 16 * status, 44, 16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage == 2
      imagepos.push([sprintf("Graphics/UI/Summary/icon_pokerus"), 390, 130])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/UI/Summary/icon_shiny"), 344, 118])
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)

    # Write various bits of text
    pagename = [_INTL(""), # INFO
                    _INTL(""), # TRAINER MEMO
                    _INTL(""), # SKILLS
                    _INTL(""), # MOVES
                    _INTL("")] # RIBBONS
                    [page - 1]
    textpos = [
      #[pagename, 26, 22, :left, base, shadow],
      [@pokemon.name, 344, 58, :left, base, shadow, true],
      [@pokemon.level.to_s, 370, 96, :left, base, shadow, true],
      [_INTL(""), 66, 324, :left, base, shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 266, 354, :left, base, shadow, true])
    else
      textpos.push([_INTL("None"), 266, 354, :left, base, shadow, true])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"), 490, 56, :left, Color.new(24, 112, 216), Color.new(136, 168, 208)])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"), 490, 56, :left, Color.new(248, 56, 32), Color.new(224, 152, 144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    end
  end

  def drawPageOne
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    dexNumBase   = (@pokemon.shiny?) ? Color.new(224, 152, 144) : base
    dexNumShadow = (@pokemon.shiny?) ? Color.new(248, 60, 38) : shadow
    # If a Shadow Pokémon, draw the heart gauge area and bar
    if @pokemon.shadowPokemon?
      shadowfract = @pokemon.heart_gauge.to_f / @pokemon.max_gauge_size
      imagepos = [
        ["Graphics/UI/Summary/overlay_shadow", 224, 240],
        ["Graphics/UI/Summary/overlay_shadowbar", 242, 280, 0, 0, (shadowfract * 248).floor, -1]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
    # Write various bits of text
    textpos = [
        [_INTL(""), 238, 86, :left, base, shadow], # Dex No.
        [_INTL(""), 238, 118, :left, base, shadow],
        [@pokemon.speciesName, 250, 90, :center, base, shadow, true], # Species
        [_INTL(""), 238, 150, :left, base, shadow], # Type
        [_INTL(""), 238, 182, :left, base, shadow], # OT
        [_INTL(""), 238, 214, :left, base, shadow] # ID No.
    ]
    # Write the Regional/National Dex number
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      dexnum = @nationalDexList.index(@pokemon.species_data.species) || 0
      dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else
      ($player.pokedex.dexes_count - 1).times do |i|
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, @pokemon.species)
        break if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    if dexnum <= 0
      textpos.push(["???", 250, 60, :center, dexNumBase, dexNumShadow, true])
    else
      dexnum -= 1 if dexnumshift
      textpos.push([sprintf("%03d", dexnum), 250, 58, :center, dexNumBase, dexNumShadow, true])
    end
    # Write Original Trainer's name and ID number
    if @pokemon.owner.name.empty?
      textpos.push([_INTL("RENTAL"), 250, 182, :center, base, shadow, true])
      textpos.push(["?????", 435, 214, :center, base, shadow, true])
    else
      ownerbase   = base
      ownershadow = shadow
      case @pokemon.owner.gender
      when 0
        ownerbase = Color.new(136, 168, 208)
        ownershadow = Color.new(24, 112, 216)
      when 1
        ownerbase = Color.new(224, 152, 144)
        ownershadow = Color.new(248, 56, 32)
      end
      textpos.push([@pokemon.owner.name, 250, 166, :center, ownerbase, ownershadow, true])
      textpos.push([sprintf("%05d", @pokemon.owner.public_id), 252, 198, :center, base, shadow, true])
    end
    # Write Exp text OR heart gauge message (if a Shadow Pokémon)
    if @pokemon.shadowPokemon?
      textpos.push([_INTL("Heart Gauge"), 238, 246, :left, base, shadow])
      black_text_tag = shadowc3tag(BLACK_TEXT_BASE, BLACK_TEXT_SHADOW)
      heartmessage = [_INTL("The door to its heart is open! Undo the final lock!"),
                      _INTL("The door to its heart is almost fully open."),
                      _INTL("The door to its heart is nearly open."),
                      _INTL("The door to its heart is opening wider."),
                      _INTL("The door to its heart is opening up."),
                      _INTL("The door to its heart is tightly shut.")][@pokemon.heartStage]
      memo = black_text_tag + heartmessage
      drawFormattedTextEx(overlay, 234, 308, 264, memo)
    else
      endexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
      textpos.push([_INTL(""), 240, 246, :left, base, shadow])
      textpos.push([@pokemon.exp.to_s_formatted, 246, 243, :right, base, shadow, true]) # Total EXP. Points
      textpos.push([_INTL(""), 240, 310, :left, base, shadow])
      textpos.push([(endexp - @pokemon.exp).to_s_formatted, 246, 275, :right, base, shadow, true]) # To Next Lv
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)

    w = (@pokemon.happiness * 228).round / 255
    w = ((w / 2).round) * 2
    pbDrawImagePositions(overlay,
                         [["Graphics/UI/Summary/overlay_friendship", 14, 364, 0, 0, w, 8]])

    # Draw Pokémon type(s)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      type_x = (@pokemon.types.length == 1) ? 214 : 182 + (68 * i)
      overlay.blt(type_x, 116, @typebitmap.bitmap, type_rect)
    end
    # Draw Exp bar
    if @pokemon.level < GameData::GrowthRate.max_level
      w = @pokemon.exp_fraction * 244
      w = ((w / 2).round) * 2
      pbDrawImagePositions(overlay,
                           [["Graphics/UI/Summary/overlay_exp", 6, 310, 0, 0, w, 8]])
    end
  end

  def drawPageOneEgg
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/UI/Summary/bg_egg")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/UI/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    textpos = [
      [_INTL("TRAINER MEMO"), 26, 22, :left, base, shadow],
      [@pokemon.name, 46, 68, :left, base, shadow],
      [_INTL("Item"), 66, 324, :left, base, shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 16, 358, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      textpos.push([_INTL("None"), 16, 358, :left, Color.new(192, 200, 208), Color.new(208, 216, 224)])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    red_text_tag = shadowc3tag(RED_TEXT_BASE, RED_TEXT_SHADOW)
    black_text_tag = shadowc3tag(BLACK_TEXT_BASE, BLACK_TEXT_SHADOW)
    memo = ""
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    # Write map name egg was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    if mapname && mapname != ""
      mapname = red_text_tag + mapname + black_text_tag
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg received from {1}.", mapname) + "\n"
    else
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg.") + "\n"
    end
    memo += "\n"   # Empty line
    # Write Egg Watch blurb
    memo += black_text_tag + _INTL("\"The Egg Watch\"") + "\n"
    eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
    eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.steps_to_hatch < 10_200
    eggstate = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.steps_to_hatch < 2550
    eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.steps_to_hatch < 1275
    memo += black_text_tag + eggstate
    # Draw all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
  end

  def drawPageTwo
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    overlay = @sprites["overlay"].bitmap
    red_text_tag = shadowc3tag(RED_TEXT_BASE, RED_TEXT_SHADOW)
    black_text_tag = shadowc3tag(BLACK_TEXT_BASE, BLACK_TEXT_SHADOW)
    memo = ""
    likedtext = ""
    # Write nature
    showNature = !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
    if showNature
      nature_name = red_text_tag + @pokemon.nature.name + black_text_tag
      memo += _INTL("{1} nature.", nature_name) + "\n"
    end
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    # Write map name Pokémon was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
    memo += red_text_tag + mapname + "\n"
    # Write how Pokémon was obtained
    mettext = [
      _INTL("Met at Lv. {1}.", @pokemon.obtain_level),
      _INTL("Egg received."),
      _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
      "",
      _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)
    ][@pokemon.obtain_method]
    memo += black_text_tag + mettext + "\n" if mettext && mettext != ""
    # If Pokémon was hatched, write when and where it hatched
    if @pokemon.obtain_method == 1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
      end
      mapname = pbGetMapNameFromId(@pokemon.hatched_map)
      mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
      memo += red_text_tag + mapname + "\n"
      memo += black_text_tag + _INTL("Egg hatched.") + "\n"
    else
      memo += "\n"   # Empty line
    end
    likedtext += black_text_tag + "\n"
    if @pokemon.likeditem
      likedtext += (_INTL("{1}", @pokemon.likeditem.name)) + "\n"
    else
      likedtext += (_INTL("None.")) + "\n"
    end
    if @pokemon.dislikeditem
      likedtext += (_INTL("{1}", @pokemon.dislikeditem.name))
    else
      likedtext += (_INTL("None."))
    end
    # Write characteristic
    if showNature
      best_stat = nil
      best_iv = 0
      stats_order = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE]
      start_point = @pokemon.personalID % stats_order.length   # Tiebreaker
      stats_order.length.times do |i|
        stat = stats_order[(i + start_point) % stats_order.length]
        if !best_stat || @pokemon.iv[stat] > @pokemon.iv[best_stat]
          best_stat = stat
          best_iv = @pokemon.iv[best_stat]
        end
      end
      characteristics = {
        :HP              => [_INTL("Loves to eat."),
                             _INTL("Takes plenty of siestas."),
                             _INTL("Nods off a lot."),
                             _INTL("Scatters things often."),
                             _INTL("Likes to relax.")],
        :ATTACK          => [_INTL("Proud of its power."),
                             _INTL("Likes to thrash about."),
                             _INTL("A little quick tempered."),
                             _INTL("Likes to fight."),
                             _INTL("Quick tempered.")],
        :DEFENSE         => [_INTL("Sturdy body."),
                             _INTL("Capable of taking hits."),
                             _INTL("Highly persistent."),
                             _INTL("Good endurance."),
                             _INTL("Good perseverance.")],
        :SPECIAL_ATTACK  => [_INTL("Highly curious."),
                             _INTL("Mischievous."),
                             _INTL("Thoroughly cunning."),
                             _INTL("Often lost in thought."),
                             _INTL("Very finicky.")],
        :SPECIAL_DEFENSE => [_INTL("Strong willed."),
                             _INTL("Somewhat vain."),
                             _INTL("Strongly defiant."),
                             _INTL("Hates to lose."),
                             _INTL("Somewhat stubborn.")],
        :SPEED           => [_INTL("Likes to run."),
                             _INTL("Alert to sounds."),
                             _INTL("Impetuous and silly."),
                             _INTL("Somewhat of a clown."),
                             _INTL("Quick to flee.")]
      }
      traits = ""
      traits += black_text_tag + characteristics[best_stat][best_iv % 5] + "\n"
    end
    # Write all text
    drawFormattedTextEx(overlay, 162, 28, 320, likedtext)
    drawFormattedTextEx(overlay, 12, 136, 320, memo)
    drawFormattedTextEx(overlay, 12, 296, 244, traits)

    w = (@pokemon.happiness * 228).round / 255
    w = ((w / 2).round) * 2
    pbDrawImagePositions(overlay,
                         [["Graphics/UI/Summary/overlay_friendship", 14, 364, 0, 0, w, 8]])

  end

  def drawPageThree
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(248, 56, 32) if change[1] > 0
        statshadows[change[0]] = Color.new(24, 112, 216) if change[1] < 0
      end
    end
    # Write various bits of text
    totaliv = 0
        ivcommands = []
        iv_id = []
        GameData::Stat.each_main do |s|
          ivcommands.push(s.name + " (#{@pokemon.iv[s.id]})")
          iv_id.push(s.id)
          totaliv += @pokemon.iv[s.id]
        end

        y_Stats = 108
        y_IVs = 178

        textpos = [
          # Stats
          [sprintf("%d", @pokemon.totalhp), 32, y_Stats, :center, base, statshadows[:HP], true],
          [sprintf("%d", @pokemon.attack), 86, y_Stats, :center, base, statshadows[:ATTACK], true],
          [sprintf("%d", @pokemon.defense), 140, y_Stats, :center, base, statshadows[:DEFENSE], true],
          [sprintf("%d", @pokemon.spatk), 194, y_Stats, :center, base, statshadows[:SPECIAL_ATTACK], true],
          [sprintf("%d", @pokemon.spdef), 248, y_Stats, :center, base, statshadows[:SPECIAL_DEFENSE], true],
          [sprintf("%d", @pokemon.speed), 302, y_Stats, :center, base, statshadows[:SPEED], true],

          # IVs
          [sprintf("%d", @pokemon.iv[:HP]), 32, y_IVs, :center, base, shadow, true],
          [sprintf("%d", @pokemon.iv[:ATTACK]), 86, y_IVs, :center, base, shadow, true],
          [sprintf("%d", @pokemon.iv[:DEFENSE]), 140, y_IVs, :center, base, shadow, true],
          [sprintf("%d", @pokemon.iv[:SPECIAL_ATTACK]), 194, y_IVs, :center, base, shadow, true],
          [sprintf("%d", @pokemon.iv[:SPECIAL_DEFENSE]), 248, y_IVs, :center, base, shadow, true],
          [sprintf("%d", @pokemon.iv[:SPEED]), 302, y_IVs, :center, base, shadow, true],

          [sprintf("%d", 100 * totaliv / (iv_id.length * Pokemon::IV_STAT_LIMIT)), 308, 143, :right, base, shadow, true],

          [_INTL(""), 224, 290, 0, base, shadow]
        ]
    # Draw ability name and description
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name, 14, 224, :left, base, shadow, true])
      drawFormattedTextEx(overlay, 12, 256, 238, shadowc3tag(BLACK_TEXT_BASE, BLACK_TEXT_SHADOW) + ability.description)
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw HP bar
    if @pokemon.hp > 0
      w = @pokemon.hp * 154 / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      imagepos = [
        ["Graphics/UI/Summary/overlay_hp", 168, 56, 0, hpzone * 6, w, 6]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
  end

  def drawPageFour
    @sprites["bg"].visible = true
    overlay = @sprites["overlay"].bitmap
    moveBase   = Color.new(224, 232, 232)
    moveShadow = Color.new(64, 64, 64)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248, 192, 0),    # 1/2 of total PP or less
                Color.new(248, 136, 32),   # 1/4 of total PP or less
                Color.new(248, 72, 72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144, 104, 0),   # 1/2 of total PP or less
                Color.new(144, 72, 24),   # 1/4 of total PP or less
                Color.new(136, 48, 48)]   # Zero PP
    @sprites["pokemon"].visible  = true
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"].visible = true
    textpos  = []
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 58
    Pokemon::MAX_MOVES.times do |i|
      move = @pokemon.moves[i]
      if move
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        imagepos.push([_INTL("Graphics/UI/types"), 8, yPos - 4, 0, type_number * 28, 64, 28])
        textpos.push([move.name, 76, yPos, :left, moveBase, moveShadow, true])
        if move.total_pp > 0
          textpos.push([_INTL("PP"), 98, yPos + 30, :left, moveBase, moveShadow, true])
          ppfraction = 0
          if move.pp == 0
            ppfraction = 3
          elsif move.pp * 4 <= move.total_pp
            ppfraction = 2
          elsif move.pp * 2 <= move.total_pp
            ppfraction = 1
          end
          textpos.push([sprintf("%d/%d", move.pp, move.total_pp), 218, yPos + 30, :right, ppBase[ppfraction], ppShadow[ppfraction], true])
        end
#      else
#        textpos.push(["-", 316, yPos, :left, moveBase, moveShadow])
#        textpos.push(["--", 442, yPos + 32, :right, moveBase, moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)

    w = (@pokemon.happiness * 228).round / 255
    w = ((w / 2).round) * 2
    pbDrawImagePositions(overlay,
                         [["Graphics/UI/Summary/overlay_friendship", 14, 364, 0, 0, w, 8]])

  end

  def drawPageFourSelecting(move_to_learn)
    @sprites["bg"].visible = true
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    moveBase   = Color.new(64, 64, 64)
    moveShadow = Color.new(176, 176, 176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248, 192, 0),    # 1/2 of total PP or less
                Color.new(248, 136, 32),   # 1/4 of total PP or less
                Color.new(248, 72, 72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144, 104, 0),   # 1/2 of total PP or less
                Color.new(144, 72, 24),   # 1/4 of total PP or less
                Color.new(136, 48, 48)]   # Zero PP
    # Set background image
    if move_to_learn
      @sprites["background"].setBitmap("Graphics/UI/Summary/bg_learnmove")
    else
      @sprites["background"].setBitmap("Graphics/UI/Summary/bg_movedetail")
    end
    # Write various bits of text
    textpos = [
      [_INTL(""), 26, 22, :left, base, shadow],
      [_INTL(""), 20, 128, :left, base, shadow],
      [_INTL(""), 20, 160, :left, base, shadow],
      [_INTL(""), 20, 192, :left, base, shadow]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 104
    yPos -= 76 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    limit.times do |i|
      move = @pokemon.moves[i]
      if i == Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 20
      end
      if move
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        imagepos.push([_INTL("Graphics/UI/types"), 246, yPos - 6, 0, type_number * 28, 64, 28])
        textpos.push([move.name, 316, yPos, :left, moveBase, moveShadow])
        if move.total_pp > 0
          textpos.push([_INTL("PP"), 342, yPos + 28, :left, moveBase, moveShadow])
          ppfraction = 0
          if move.pp == 0
            ppfraction = 3
          elsif move.pp * 4 <= move.total_pp
            ppfraction = 2
          elsif move.pp * 2 <= move.total_pp
            ppfraction = 1
          end
          textpos.push([sprintf("%d/%d", move.pp, move.total_pp), 460, yPos + 32, :right,
                        ppBase[ppfraction], ppShadow[ppfraction], true])
        end
#      else
#        textpos.push(["-", 316, yPos, :left, moveBase, moveShadow])
#        textpos.push(["--", 442, yPos + 32, :right, moveBase, moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
    # Draw Pokémon's type icon(s)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      type_x = (@pokemon.types.length == 1) ? 130 : 96 + (70 * i)
      overlay.blt(type_x, 54, @typebitmap.bitmap, type_rect)
    end
  end

  def drawSelectedMove(move_to_learn, selected_move)
    # Draw all of page four, except selected move's details
    drawPageFourSelecting(move_to_learn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["bg"].visible = true

    @sprites["pkmnup"].visible = false if @sprites["pokemon"]
    @sprites["pkmndown"].visible = false if @sprites["pokemon"]
    @sprites["pkmnright"].visible = false if @sprites["pokemon"]
    @sprites["pkmnleft"].visible = false if @sprites["pokemon"]

    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["pokeicon"].visible = true
    @sprites["itemicon"].visible = false if @sprites["itemicon"]

    @sprites["itemiconup"].visible = false if @sprites["itemicon"]
    @sprites["itemicondown"].visible = false if @sprites["itemicon"]
    @sprites["itemiconleft"].visible = false if @sprites["itemicon"]
    @sprites["itemiconright"].visible = false if @sprites["itemicon"]

    textpos = []
    y_power = 132
    y_acc = 164
    # Write power and accuracy values for selected move
    case selected_move.display_damage(@pokemon)
    when 0 then textpos.push(["---", 216, y_power, :right, base, shadow])   # Status move
    when 1 then textpos.push(["???", 216, y_power, :right, base, shadow])   # Variable power move
    else        textpos.push([selected_move.display_damage(@pokemon).to_s, 216, y_power, :right, base, shadow])
    end
    if selected_move.display_accuracy(@pokemon) == 0
      textpos.push(["---", 216, y_acc, :right, base, shadow])
    else
      textpos.push(["#{selected_move.display_accuracy(@pokemon)}%", 216 + overlay.text_size("%").width, y_acc, :right, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/UI/category", 166, 94, 0, selected_move.display_category(@pokemon) * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
    # Draw selected move's description
    drawTextEx(overlay, 4, 194, 228, 6, selected_move.description, base, shadow)
  end

  def drawPageFive
    overlay = @sprites["overlay"].bitmap
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    # Write various bits of text
    textpos = [
      [@pokemon.numRibbons.to_s + " / 16", 294, 100, 2, base, shadow, true]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Show all ribbons
    imagepos = []
    coord = 0
    (@ribbonOffset * 4...(@ribbonOffset * 4) + 16).each do |i|
      break if !@pokemon.ribbons[i]
      ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[i])
      ribn = ribbon_data.icon_position
      imagepos.push(["Graphics/UI/Summary/ribbons",
                     30 + (68 * (coord % 4)),
                     78 + (68 * (coord / 4).floor),
                     64 * (ribn % 8),
                     64 * (ribn / 8).floor,
                     64,
                     64])
      coord += 1
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)

    w = (@pokemon.happiness * 228).round / 255
    w = ((w / 2).round) * 2
    pbDrawImagePositions(overlay,
                         [["Graphics/UI/Summary/overlay_friendship", 14, 364, 0, 0, w, 8]])

  end

  def drawSelectedRibbon(ribbonid)
    # Draw all of page five
    drawPage(5)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)
    nameBase   = Color.new(248, 248, 248)
    nameShadow = Color.new(104, 104, 104)
    # Get data for selected ribbon
    name = ribbonid ? GameData::Ribbon.get(ribbonid).name : ""
    desc = ribbonid ? GameData::Ribbon.get(ribbonid).description : ""
    # Draw the description box
    imagepos = [
      ["Graphics/UI/Summary/overlay_ribbon", 8, 280]
    ]
    pbDrawImagePositions(overlay, imagepos)
    # Draw name of selected ribbon
    textpos = [
      [name, 18, 292, :left, nameBase, nameShadow]
    ]
    pbDrawTextPositions(overlay, textpos)
    # Draw selected ribbon's description
    drawTextEx(overlay, 18, 324, 480, 2, desc, base, shadow)
  end

  def pbGoToPrevious
    newindex = @partyindex
    while newindex > 0
      newindex -= 1
      if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
        @partyindex = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @partyindex
    while newindex < @party.length - 1
      newindex += 1
      if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
        @partyindex = newindex
        break
      end
    end
  end

  def pbChangePokemon
    @pokemon = @party[@partyindex]
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["itemicon"].item = @pokemon.item_id
    pbSEStop
    @pokemon.play_cry
  end

  def pbMoveSelection
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    selmove    = 0
    oldselmove = 0
    switching = false
    drawSelectedMove(nil, @pokemon.moves[selmove])
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["movepresel"].index == @sprites["movesel"].index
        @sprites["movepresel"].z = @sprites["movesel"].z + 1
      else
        @sprites["movepresel"].z = @sprites["movesel"].z
      end
      if Input.trigger?(Input::BACK)
        (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
        break if !switching
        @sprites["movepresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if selmove == Pokemon::MAX_MOVES
          break if !switching
          @sprites["movepresel"].visible = false
          switching = false
        elsif !@pokemon.shadowPokemon?
          if switching
            tmpmove                    = @pokemon.moves[oldselmove]
            @pokemon.moves[oldselmove] = @pokemon.moves[selmove]
            @pokemon.moves[selmove]    = tmpmove
            @sprites["movepresel"].visible = false
            switching = false
            drawSelectedMove(nil, @pokemon.moves[selmove])
          else
            @sprites["movepresel"].index   = selmove
            @sprites["movepresel"].visible = true
            oldselmove = selmove
            switching = true
          end
        end
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        selmove = 0 if selmove >= Pokemon::MAX_MOVES
        selmove = @pokemon.numMoves - 1 if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE
        drawSelectedMove(nil, @pokemon.moves[selmove])
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
        selmove = 0 if selmove >= Pokemon::MAX_MOVES
        selmove = Pokemon::MAX_MOVES if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE
        drawSelectedMove(nil, @pokemon.moves[selmove])
      end
    end
    @sprites["movesel"].visible = false
  end

  def pbRibbonSelection
    @sprites["ribbonsel"].visible = true
    @sprites["ribbonsel"].index   = 0
    selribbon    = @ribbonOffset * 4
    oldselribbon = selribbon
    switching = false
    numRibbons = @pokemon.ribbons.length
    numRows    = [((numRibbons + 3) / 4).floor, 4].max
    drawSelectedRibbon(@pokemon.ribbons[selribbon])
    loop do
      @sprites["uparrow"].visible   = (@ribbonOffset > 0)
      @sprites["downarrow"].visible = (@ribbonOffset < numRows - 3)
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["ribbonpresel"].index == @sprites["ribbonsel"].index
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z + 1
      else
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z
      end
      hasMovedCursor = false
      if Input.trigger?(Input::BACK)
        (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
        break if !switching
        @sprites["ribbonpresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::USE)
        if switching
          pbPlayDecisionSE
          tmpribbon                      = @pokemon.ribbons[oldselribbon]
          @pokemon.ribbons[oldselribbon] = @pokemon.ribbons[selribbon]
          @pokemon.ribbons[selribbon]    = tmpribbon
          if @pokemon.ribbons[oldselribbon] || @pokemon.ribbons[selribbon]
            @pokemon.ribbons.compact!
            if selribbon >= numRibbons
              selribbon = numRibbons - 1
              hasMovedCursor = true
            end
          end
          @sprites["ribbonpresel"].visible = false
          switching = false
          drawSelectedRibbon(@pokemon.ribbons[selribbon])
        else
          if @pokemon.ribbons[selribbon]
            pbPlayDecisionSE
            @sprites["ribbonpresel"].index = selribbon - (@ribbonOffset * 4)
            oldselribbon = selribbon
            @sprites["ribbonpresel"].visible = true
            switching = true
          end
        end
      elsif Input.trigger?(Input::UP)
        selribbon -= 4
        selribbon += numRows * 4 if selribbon < 0
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        selribbon += 4
        selribbon -= numRows * 4 if selribbon >= numRows * 4
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        selribbon -= 1
        selribbon += 4 if selribbon % 4 == 3
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT)
        selribbon += 1
        selribbon -= 4 if selribbon % 4 == 0
        hasMovedCursor = true
        pbPlayCursorSE
      end
      next if !hasMovedCursor
      @ribbonOffset = (selribbon / 4).floor if selribbon < @ribbonOffset * 4
      @ribbonOffset = (selribbon / 4).floor - 2 if selribbon >= (@ribbonOffset + 3) * 4
      @ribbonOffset = 0 if @ribbonOffset < 0
      @ribbonOffset = numRows - 3 if @ribbonOffset > numRows - 3
      @sprites["ribbonsel"].index    = selribbon - (@ribbonOffset * 4)
      @sprites["ribbonpresel"].index = oldselribbon - (@ribbonOffset * 4)
      drawSelectedRibbon(@pokemon.ribbons[selribbon])
    end
    @sprites["ribbonsel"].visible = false
  end

  def pbMarking(pokemon)
    @sprites["markingbg"].visible      = true
    @sprites["markingoverlay"].visible = true
    @sprites["markingsel"].visible     = true
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    ret = pokemon.markings.clone
    markings = pokemon.markings.clone
    mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
    index = 0
    redraw = true
    markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
          markrect.x = i * MARK_WIDTH
          markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
          @sprites["markingoverlay"].bitmap.blt(300 + (58 * (i % 3)), 154 + (50 * (i / 3)),
                                                @markingbitmap.bitmap, markrect)
        end
        textpos = [
          [_INTL("Mark {1}", pokemon.name), 366, 102, :center, base, shadow],
          [_INTL("OK"), 366, 254, :center, base, shadow],
          [_INTL("Cancel"), 366, 304, :center, base, shadow]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
        redraw = false
      end
      # Reposition the cursor
      @sprites["markingsel"].x = 284 + (58 * (index % 3))
      @sprites["markingsel"].y = 144 + (50 * (index / 3))
      case index
      when 6   # OK
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 244
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
      when 7   # Cancel
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 294
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
      else
        @sprites["markingsel"].src_rect.y = 0
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        case index
        when 6   # OK
          ret = markings
          break
        when 7   # Cancel
          break
        else
          markings[index] = ((markings[index] || 0) + 1) % mark_variants
          redraw = true
        end
      elsif Input.trigger?(Input::ACTION)
        if index < 6 && markings[index] > 0
          pbPlayDecisionSE
          markings[index] = 0
          redraw = true
        end
      elsif Input.trigger?(Input::UP)
        if index == 7
          index = 6
        elsif index == 6
          index = 4
        elsif index < 3
          index = 7
        else
          index -= 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        if index == 7
          index = 1
        elsif index == 6
          index = 7
        elsif index >= 3
          index = 6
        else
          index += 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        if index < 6
          index -= 1
          index += 3 if index % 3 == 2
          pbPlayCursorSE
        end
      elsif Input.trigger?(Input::RIGHT)
        if index < 6
          index += 1
          index -= 3 if index % 3 == 0
          pbPlayCursorSE
        end
      end
    end
    @sprites["markingbg"].visible      = false
    @sprites["markingoverlay"].visible = false
    @sprites["markingsel"].visible     = false
    if pokemon.markings != ret
      pokemon.markings = ret
      return true
    end
    return false
  end

  def pbOptions
    dorefresh = false
    commands = []
    cmdGiveItem = -1
    cmdTakeItem = -1
    cmdPokedex  = -1
    cmdMark     = -1
    if !@pokemon.egg?
      commands[cmdGiveItem = commands.length] = _INTL("Give item")
      commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
      commands[cmdPokedex = commands.length]  = _INTL("View Pokédex") if $player.has_pokedex
    end
    commands[cmdMark = commands.length]       = _INTL("Mark")
    commands[commands.length]                 = _INTL("Cancel")
    command = pbShowCommands(commands)
    if cmdGiveItem >= 0 && command == cmdGiveItem
      item = nil
      pbFadeOutIn do
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        item = screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
      end
      dorefresh = pbGiveItemToPokemon(item, @pokemon, self, @partyindex) if item
    elsif cmdTakeItem >= 0 && command == cmdTakeItem
      dorefresh = pbTakeItemFromPokemon(@pokemon, self)
    elsif cmdPokedex >= 0 && command == cmdPokedex
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      end
      dorefresh = true
    elsif cmdMark >= 0 && command == cmdMark
      dorefresh = pbMarking(@pokemon)
    end
    return dorefresh
  end

  def pbChooseMoveToForget(move_to_learn)
    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    selmove = 0
    maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        selmove = Pokemon::MAX_MOVES
        pbPlayCloseMenuSE if new_move
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        selmove = maxmove if selmove < 0
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        @sprites["movesel"].index = selmove
        selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
        drawSelectedMove(new_move, selected_move)
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove > maxmove
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = (new_move) ? maxmove : 0
        end
        @sprites["movesel"].index = selmove
        selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
        drawSelectedMove(new_move, selected_move)
      end
    end
    return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
  end

  def pbScene
    @pokemon.play_cry
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        @pokemon.play_cry
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page == 4
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif @page == 5
          pbPlayDecisionSE
          pbRibbonSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex > 0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        @page = 5 if @page > 5
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page < 1
        @page = 5 if @page > 5
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      drawPage(@page) if dorefresh
    end
    return @partyindex
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSummaryScreen
  def initialize(scene, inbattle = false)
    @scene = scene
    @inbattle = inbattle
  end

  def pbStartScreen(party, partyindex)
    @scene.pbStartScene(party, partyindex, @inbattle)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party, partyindex, move_to_learn)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, move_to_learn)
    loop do
      ret = @scene.pbChooseMoveToForget(move_to_learn)
      break if ret < 0 || !move_to_learn
      break if $DEBUG || !party[partyindex].moves[ret].hidden_move?
      pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party, partyindex, message)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, nil)
    pbMessage(message) { @scene.pbUpdate }
    loop do
      ret = @scene.pbChooseMoveToForget(nil)
      break if ret >= 0
      pbMessage(_INTL("You must choose a move!")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbChooseMove(pokemon, variableNumber, nameVarNumber)
  return if !pokemon
  ret = -1
  pbFadeOutIn do
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    ret = screen.pbStartForgetScreen([pokemon], 0, nil)
  end
  $game_variables[variableNumber] = ret
  if ret >= 0
    $game_variables[nameVarNumber] = pokemon.moves[ret].name
  else
    $game_variables[nameVarNumber] = ""
  end
  $game_map.need_refresh = true if $game_map
end
