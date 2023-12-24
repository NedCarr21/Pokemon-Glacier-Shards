################################################################################
#                               Item Crafting UI                               #
#                               by ThatWelshOne_                               #
#    Refer to the resource post for instructions on how to use this script.    #
################################################################################

class ItemCraft_Scene
  
  BASELIGHT        = Color.new(248,248,248)
  SHADOWLIGHT      = Color.new(72,80,88)
  BASEDARK         = Color.new(80,80,88)
  SHADOWDARK       = Color.new(160,160,168)
  MOVINGBACKGROUND = true
  FLAG_TO_TEXT     = {
        "berry" => _INTL("Any Berry")
  }
  
  def initialize
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @adapter = PokemonMartAdapter.new
  end
  
  def pbStartScene
    addBackgroundPlane(@sprites,"bg","Crafting/bg",@viewport)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/UI/Crafting/base")
    @sprites["base"].ox = @sprites["base"].bitmap.width/2
    @sprites["base"].oy = @sprites["base"].bitmap.height/2
    @sprites["base"].x = Graphics.width/2; @sprites["base"].y = Graphics.height/2 - 16
    @h = @sprites["base"].y - @sprites["base"].oy
    @w = @sprites["base"].x - @sprites["base"].ox
    @xPos = [@w + 70,
             @w + 256]
    @yPos = [@h + 160,
             @h + 212,
             @h + 262]
    @sprites["item"] = ItemIconSprite.new(@w+44,@h+68,nil,@viewport)
    6.times do |i|
      @sprites["ingredient_#{i}"] = ItemIconSprite.new(0,0,nil,@viewport)
      @sprites["ingredient_#{i}"].x = @w + 38
      @sprites["ingredient_#{i}"].x += 186 if i>2
      @sprites["ingredient_#{i}"].y = @h + 198 + (i%3)*48
      @sprites["ingredient_#{i}"].visible = false
    end
    @sprites["itemtext"] = Window_UnformattedTextPokemon.new("")
    @sprites["itemtext"].x = @w + 82
    @sprites["itemtext"].y = @h + 20
    @sprites["itemtext"].width = 360
    @sprites["itemtext"].height = 160
    @sprites["itemtext"].baseColor = BASEDARK
    @sprites["itemtext"].shadowColor = SHADOWDARK
    @sprites["itemtext"].visible = true
    @sprites["itemtext"].viewport = @viewport
    @sprites["itemtext"].windowskin = nil
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/UI/right_arrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width - @sprites["rightarrow"].bitmap.width
    @sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/UI/left_arrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play
    @sprites["bottombar"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["bottombar"].bitmap.fill_rect(0,Graphics.height-32,Graphics.width,32,Color.new(144,184,240))
    @sprites["bottombar"].visible = true
    @sprites["overlay1"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay1 = @sprites["overlay1"].bitmap
    pbSetSystemFont(@overlay1)
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay2 = @sprites["overlay2"].bitmap
    pbSetSystemFont(@overlay2)
  end
  
  def pbCraftItem(stock)
    index = 0
    volume = 1
    @stock = stock
    @switching = false
    refreshNumbers(index,volume)
    pbRedrawItem(index,volume)
    pbFadeInAndShow(@sprites) { pbUpdate }
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        if index < @stock.length-1
          pbPlayCursorSE
          hideIcons(index)
          volume = 1
          index += 1
          @switching = true
          pbRedrawItem(index,volume)
        end
      end
      if Input.trigger?(Input::LEFT)
        if index > 0
          pbPlayCursorSE
          hideIcons(index)
          volume = 1
          index -= 1
          @switching = true
          pbRedrawItem(index,volume)
        end
      end
      if Input.trigger?(Input::UP)
        if volume < 99
          pbPlayCursorSE
          volume += 1
          refreshNumbers(index,volume)
        elsif volume == 99
          pbPlayCursorSE
          volume = 1
          refreshNumbers(index,volume)
        end
      end
      if Input.trigger?(Input::DOWN)
        if volume > 1
          pbPlayCursorSE
          volume -= 1
          refreshNumbers(index,volume)
        elsif volume == 1
          pbPlayCursorSE
          volume = 99
          refreshNumbers(index,volume)
        end
      end
      if Input.trigger?(Input::USE)
        recipe_data = GameData::Recipe.get(@stock[index])
        item = GameData::Item.get(recipe_data.item)
        itemname = (volume>1) ? item.name_plural : item.name
        pocket = item.pocket
        if pbConfirmMessage(_INTL("Would you like to craft {1} {2}?",volume*recipe_data.yield,itemname)) { pbUpdate }
          if canCraft?(index,volume)
            added = 0
            quantity = (volume*recipe_data.yield)
            quantity.times do
              break if !@adapter.addItem(item)
              added += 1
            end
            if added == quantity
              pbSEPlay("Pkmn move learnt")
              removeIngredients(index,volume)
              pbMessage(_INTL("You put {1} {2} away\\nin the <icon=bagPocket{3}>\\c[1]{4} Pocket\\c[0].",
                quantity,itemname,pocket,PokemonBag.pocket_names()[pocket - 1])) { pbUpdate }
              refreshNumbers(index,volume)
            else
              added.times do
                if !@adapter.removeItem(item)
                  raise _INTL("Failed to delete stored items")
                end
              end
              pbPlayBuzzerSE
              pbMessage(_INTL("Too bad...\nThe Bag is full...")) { pbUpdate }
            end
          else
            pbPlayBuzzerSE
            pbMessage(_INTL("You lack the necessary ingredients.")) { pbUpdate }
          end
        end
      end
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
  end
  
  def removeIngredients(index,volume)
    ingredients = GameData::Recipe.get(@stock[index]).ingredients
    ingredients.length.times do |i|
      ingredient = ingredients[i][0]
      cost = ingredients[i][1]
      if ingredient.is_a?(Symbol)
        (volume*cost).times { @adapter.removeItem(ingredient) }
      else
        valid_items = []
        GameData::Item.each do |item|
          next if !item.has_flag?(ingredient)
          valid_items.push([item.id, item.price])
        end
        valid_items = valid_items.sort_by.with_index {|x,i| [x[1],i] }
        (volume*cost).times do
          valid_items.each do |item|
            next unless @adapter.getQuantity(item[0])>0
            @adapter.removeItem(item[0])
            break
          end
        end
      end
    end
  end
  
  def canCraft?(index,volume)
    ret = []
    ingredients = GameData::Recipe.get(@stock[index]).ingredients
    ingredients.length.times do |i|
      ingredient = ingredients[i][0]
      cost = ingredients[i][1]
      have = 0
      if ingredient.is_a?(Symbol)
        have=@adapter.getQuantity(ingredient)
      else
        GameData::Item.each do |item|
          next if !item.has_flag?(ingredient)
          have+=@adapter.getQuantity(item)
        end
      end
      return false if have < volume*cost
    end
    return true
  end
  
  def hideIcons(index)
    num = GameData::Recipe.get(@stock[index]).ingredients.length # Number of ingredients
    num.times do |i|
      @sprites["ingredient_#{i}"].visible = false
    end
  end
  
  def refreshNumbers(index,volume)
    @overlay2.clear
    ingredients = GameData::Recipe.get(@stock[index]).ingredients
    textpos = []
    textpos.push([_INTL("x{1}",volume),@w+26,@h+106,0,BASEDARK,SHADOWDARK])
    ingredients.length.times do |i|
      ingredient = ingredients[i][0]
      quantity = ingredients[i][1]
      bag_qty = 0
      if ingredient.is_a?(Symbol)
        bag_qty=@adapter.getQuantity(ingredient)
      else
        GameData::Item.each do |item|
          next if !item.has_flag?(ingredient)
          bag_qty+=@adapter.getQuantity(item)
        end
      end
      text = sprintf("% 3d /% 3d",bag_qty,volume*quantity)
      textpos.push([text,
      @xPos[i/3],
      @yPos[i%3] + 38,
      0,
      (bag_qty >= volume*quantity) ? BASEDARK : Color.new(248,192,0),
      (bag_qty >= volume*quantity) ? SHADOWDARK : Color.new(144,104,0)])
    end
    pbDrawTextPositions(@overlay2,textpos)
  end
  
  def pbRedrawItem(index,volume)
    refreshNumbers(index,volume) if @switching
    @sprites["rightarrow"].visible = (index < @stock.length-1) ? true : false
    @sprites["leftarrow"].visible = (index > 0) ? true : false
    @overlay1.clear
    recipe_data = GameData::Recipe.get(@stock[index])
    item = GameData::Item.get(recipe_data.item)
    @sprites["item"].item = item.id
    @sprites["itemtext"].text = item.description
    ingredients = recipe_data.ingredients
    textpos = [
    ["USE: Craft",4,Graphics.height-26,0,BASELIGHT,SHADOWLIGHT],
    ["ARROWS: Navigate",Graphics.width/2,Graphics.height-26,2,BASELIGHT,SHADOWLIGHT],
    ["BACK: Exit",Graphics.width-4,Graphics.height-26,1,BASELIGHT,SHADOWLIGHT]
    ]
    textpos.push([sprintf("%s x%d", item.name,recipe_data.yield),@w+98,@h+12,0,BASEDARK,SHADOWDARK])
    ingredients.length.times do |i|
      ingredient = ingredients[i][0]
      quantity = ingredients[i][1]
      if ingredient.is_a?(Symbol)
        @sprites["ingredient_#{i}"].item = ingredient
        ingredient_name = GameData::Item.get(ingredient).name
      else
        @sprites["ingredient_#{i}"].flag = ingredient
        ingredient_name = FLAG_TO_TEXT[ingredient.downcase] || ingredient
        ingredient_name = _INTL(ingredient_name)
      end
      @sprites["ingredient_#{i}"].visible = true
      textpos.push([ingredient_name,
      @xPos[i/3],
      @yPos[i%3] + 12,
      0,BASEDARK,SHADOWDARK])
    end
    pbDrawTextPositions(@overlay1,textpos)
    @switching = false
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["bg"] && MOVINGBACKGROUND
      @sprites["bg"].ox-=1
      @sprites["bg"].oy-=1
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end


class ItemCraft_Screen
  def initialize(scene,stock)
    @scene = scene
    @stock = stock
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbCraftItem(@stock)
    @scene.pbEndScene
  end
end

class ItemIconSprite
  attr_reader :flag
  
  alias _itemcrafter_initialize initialize
  def initialize(*args)
    _itemcrafter_initialize(*args)
    @flag = nil
  end
  
  alias :_itemcrafter_item= :item=
  def item=(value)
    self._itemcrafter_item=value
    @flag = nil
  end
  
  def flag=(value)
    return if @flag == value && !@forceitemchange
    @flag = value
    @animbitmap&.dispose
    @animbitmap = nil
    if @flag || !@blankzero
      @animbitmap = AnimatedBitmap.new(GameData::Item.flag_icon_filename(@flag))
      self.bitmap = @animbitmap.bitmap
      if self.bitmap.height == ANIM_ICON_SIZE
        @numframes = [(self.bitmap.width / ANIM_ICON_SIZE).floor, 1].max
        self.src_rect = Rect.new(0, 0, ANIM_ICON_SIZE, ANIM_ICON_SIZE)
      else
        @numframes = 1
        self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
      end
      @animframe = 0
      @frame = 0
    else
      self.bitmap = nil
    end
    changeOrigin
    @item = nil
  end
end

def pbItemCrafter(stock,speech1=nil,speech2=nil)
  stock.each do |recipe|
    raise _INTL("Invalid Recipe ID {1}.", recipe) if !GameData::Recipe.exists?(recipe)
  end
  stock.uniq!
  if stock.empty?
    pbMessage(_INTL("You don't have any recipes to use here."))
    return
  end
  if pbConfirmMessage(_INTL("Would you like to craft something?"))
    pbMessage(speech1 ? speech1 : _INTL("Let's get started!"))
    pbFadeOutIn {
      scene = ItemCraft_Scene.new
      screen = ItemCraft_Screen.new(scene,stock)
      screen.pbStartScreen
    }
  end
  pbMessage(speech2 ? speech2 : _INTL("Come back soon!"))
end
