module WheelData
  DEFAULT_BACKGROUND = "hatchbg"
  DEFAULT_WHEEL      = "prizewheel"
  DEFAULT_RADIUS     = 110
  DEFAULT_MINSPINS   = 3
  DEFAULT_RESPIN     = true
  DEFAULT_COST       = 0
  DEFAULT_COSTCOINS  = false
  DEFAULT_PRIZECOINS = false
  DEFAULT_SPINSFX    = ["battle ball shake",80,150]
  DEFUALT_WINSFX     = ["mining reveal full",100,100]
  DEFAULT_LEVEL      = 20

  Wheel = {
    :background => "hatchbg",
    :wheel      => "prizewheel",
    :radius     => 110,
    :minspins   => 3,
    :respin     => false,
    :cost       => 500,
    :costcoins  => false,
    :prizecoins => false,
    :spinsfx    => ["battle ball shake",80,150],
    :winsfx     => ["mining reveal full",100,100],
    :level      => 20,
    :prizes     => [:POKEBALL,
                    :MONOBALL,
                    :GREATBALL,
                    :POKEBALL,
                    :ULTRABALL,
                    :SNOWBALLBALL,
                    :POKEBALL,
                    :DUELBALL,
                    :GREATBALL,
                    :GOLDENBALL]
  }

end

#center_origins command from Marin's Scripting Utilities.
#If you have that script, you can delete this section
class Sprite
  def center_origins
    return if !self.bitmap
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end
end



#.degrees command, to convert degrees to radians
class Numeric
   def degrees
     self * Math::PI / 180
   end
end

def pbWheel(wheeldata)
  PrizeWheelScene.new(wheeldata)
end




class PrizeWheelScene

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end


  def initialize(wheeldata)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    wheeldata = WheelData.const_get(wheeldata)
    @respin = (wheeldata[:respin]) ? wheeldata[:respin] : WheelData::DEFAULT_RESPIN
    @cost=(wheeldata[:cost]) ? wheeldata[:cost] : 0
    @costcoins = (wheeldata[:costcoins]) ? wheeldata[:costcoins] : WheelData::DEFAULT_COSTCOINS
    @prizecoins = (wheeldata[:prizecoins]) ? wheeldata[:prizecoins] : WheelData::DEFAULT_PRIZECOINS
    @prizes=wheeldata[:prizes]
    @sprites = {}
    @bg        = (wheeldata[:bg]) ? wheeldata[:bg] : WheelData::DEFAULT_BACKGROUND
    @wheel     = (wheeldata[:wheel]) ? wheeldata[:wheel] : WheelData::DEFAULT_WHEEL
    @radius    = (wheeldata[:radius]) ? wheeldata[:radius] : WheelData::DEFAULT_RADIUS
    @minspins  = (wheeldata[:minspins]) ? wheeldata[:minspins] : WheelData::DEFAULT_MINSPINS
    @spinsfx   = (wheeldata[:spinsfx]) ? wheeldata[:spinsfx] : WheelData::DEFAULT_SPINSFX
    @winsfx    = (wheeldata[:winsfx]) ? wheeldata[:winsfx] : WheelData::DEFUALT_WINSFX
    @level     = (wheeldata[:level]) ? wheeldata[:level] : WheelData::DEFAULT_LEVEL
    raise _INTL("Invalid level. (exceeds maximum level)") if @level > Settings::MAXIMUM_LEVEL
    @prizespin=0
    @angle=[72,36,0,313,287,251,216,180,144,108]
    @xyangle=[198,234,270,306,340,16,52,90,126,162]
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = Bitmap.new("Graphics/Pictures/#{@bg}")
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = (Graphics.width/2)-15
    @sprites["downarrow"].y = 10
    @sprites["downarrow"].z = 5
    @sprites["downarrow"].play
    @sprites["wheel"] = Sprite.new(@viewport)
    @sprites["wheel"].bitmap = Bitmap.new("Graphics/Pictures/#{@wheel}")
    @sprites["wheel"].center_origins
    @sprites["wheel"].x=Graphics.width/2
    @sprites["wheel"].y=Graphics.height/2
    for i in 0...10
      raise _INTL("Not enough prizes.") if !@prizes[i]
      display = @prizes[i]
      display = @prizes[i][0] if @prizes[i].is_a?(Array)
      if display.is_a?(Symbol) && !GameData::Item.try_get(display) &&
                                  !GameData::Species.try_get(display)
        raise _INTL("#{display} is not an item or species.")
      end
      if display.is_a?(Integer)
        @sprites["prize#{i}"] = Sprite.new(@viewport)
        if @prizecoins == true
          @sprites["prize#{i}"].bitmap = Bitmap.new("Graphics/Items/COINCASE")
        else
          @sprites["prize#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Money")
        end
        @sprites["prize#{i}"].center_origins
      elsif display.is_a?(String)
        @sprites["prize#{i}"] = Sprite.new(@viewport)
        @sprites["prize#{i}"].bitmap = Bitmap.new("Graphics/#{display}")
        @sprites["prize#{i}"].center_origins
      elsif GameData::Item.try_get(display)
        @sprites["prize#{i}"]=ItemIconSprite.new(0,0,nil,@viewport)
        @sprites["prize#{i}"].item = display
        @sprites["prize#{i}"].ox=24
        @sprites["prize#{i}"].oy=24
      elsif GameData::Species.try_get(display)
        @sprites["prize#{i}"]=PokemonSpeciesIconSprite.new(display,@viewport)
        @sprites["prize#{i}"].shiny = false
        @sprites["prize#{i}"].ox=32
        @sprites["prize#{i}"].oy=32
      end
      @sprites["prize#{i}"].angle = @angle[i]
      @sprites["prize#{i}"].x=(Graphics.width/2) + Math.cos(@xyangle[i].degrees)*@radius
      @sprites["prize#{i}"].y=(Graphics.height/2) + Math.sin(@xyangle[i].degrees)*@radius
    end
    main
  end

  def main
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::C)
        confirmtext="Spin the wheel?"
        confirmtext="Spin the wheel for $#{@cost}?" if @cost > 0
        confirmtext="Spin the wheel for #{@cost} coins?" if @costcoins == true
        if pbConfirmMessage("#{confirmtext}")
            if @costcoins == true && $player.coins<=@cost
               pbMessage(_INTL("You don't have enough coins..."))
                break
            elsif @costcoins == false && $player.money<=@cost
                pbMessage(_INTL("You don't have enough money..."))
                break
            end
          $player.coins-=@cost if @costcoins == true
          $player.money-=@cost if @costcoins == false
          spins=rand(360)
          spins+=360*(@minspins)
          spun=0
          click=true
          loop do
            pbUpdate
            @sprites["wheel"].angle -= 5
            @prizespin+=5
            for i in 0...10
              @sprites["prize#{i}"].angle -= 5
              @sprites["prize#{i}"].x= (Graphics.width/2) + Math.cos((@xyangle[i]+@prizespin).degrees)*@radius
              @sprites["prize#{i}"].y= (Graphics.height/2) + Math.sin((@xyangle[i]+@prizespin).degrees)*@radius
            end
            spun+=5
            Graphics.update
            if click==true
              pbSEPlay(@spinsfx[0],@spinsfx[1],@spinsfx[2])
              click=false
            else
              click=true
            end
            if spun>=spins
            prize=0
            prizey=[]
            for i in 0...10
              prizey[i]=@sprites["prize#{i}"].y
            end
             winner=prizey.min
              for i in 0...10
                if @sprites["prize#{i}"].y==winner
                   prize=i
                 end
              end
              prize=@prizes[prize]
              pbSEPlay(@winsfx[0],@winsfx[1],@winsfx[2])
              if prize.is_a?(Integer)
                if @prizecoins == true
                  pbMessage("You won #{prize} coins!")
                  $player.coins+=prize
                else
                  pbMessage("You won $#{prize}!")
                  $player.money+=prize
                end
              elsif prize.is_a?(Array)
                prize.delete_at(0)
                prize = prize.sample
              end
              pbUpdate
              pbReceiveItem(prize) if GameData::Item.try_get(prize)
              pbAddPokemon(prize,@level) if GameData::Species.try_get(prize)
              @spun = true if @respin == false
              break
            end
          end
        end
      end
      if Input.trigger?(Input::B) || @spun == true
        break
      end
    end
    pbFadeOutAndHide(@sprites) {pbUpdate}
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end
