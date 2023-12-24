#===============================================================================
# * Roulette Minigame - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It's the Roulette Game Corner minigame
# from Ruby/Sapphire/Emerald. This minigame isn't an exact adaptation of the
# official one, the ball never stops at an occupied slot, so there's no
# Taillow and Shroomish bonus.
#
#== INSTALLATION ===============================================================
#
# Put it above main or convert into a plugin. Create "Roulette" folder at
# Graphics/Pictures and put the pictures (may works with other sizes):
# -  30x30  ball
# -  16x16  ballicon
# -  16x16  ballusedicon
# - 116x56  creditbox
# -  56x32  multiplierbox
# - 306x306 roulette
# - 240x46  selectedcolor
# -  46x46  selectedsingle
# -  46x192 selectedspecies
# - 244x196 table
#
# Add on Audio/SE "Roulette Ball" and "Roulette Ball End" audio files.
#
#=== HOW TO USE ================================================================
#
# Use the script command 'roulette(X)' where X is the wager number.
#
# You can use 'roulette(1, RouletteScreen::BLUE)' to start the game with a
# different board color set. Available color sets are RED, GREEN and BLUE.
#
#=== NOTES =====================================================================
#
# Besides the already defined constants, you can pass any two position color
# array as the second parameter. The first color is the background, the second
# is the used ball icon.
#
#===============================================================================

if defined?(PluginManager) && !PluginManager.installed?("Roulette Minigame")
  PluginManager.register({
    :name    => "Roulette Minigame",
    :version => "1.1.3",
    :link    => "https://www.pokecommunity.com/showthread.php?t=318598",
    :credits => "FL"
  })
end

class RouletteScene
  TABLE_POSITIONS=[
    [1,10, 7,4],
    [5, 2,11,8],
    [9, 6, 3,0]
  ]
  COLUMNS=4
  ROWS=3
  ROUNDS=8 # Before clean the board

  class Cursor
    attr_reader :sprite
    attr_reader :indexX
    attr_reader :indexY

    def initialize(sprite,playedBalls,tableX,tableY)
      @sprite=sprite
      @sprite.x=8
      @sprite.y=8
      @playedBalls=playedBalls
      @tableX=tableX
      @tableY=tableY
      @frameCount=0
      @indexX=-1
      @indexY=-1
      setIndex(1,1)
    end

    def update
      @frameCount+=1
      @sprite.visible=!@sprite.visible if @frameCount%16==0 # Flash effect
    end

    def resetframeCount
      @frameCount=0
      @sprite.visible=true
    end

    def moveUp;   setIndex(@indexX,@indexY-1);end
    def moveDown; setIndex(@indexX,@indexY+1);end
    def moveLeft; setIndex(@indexX-1,@indexY);end
    def moveRight;setIndex(@indexX+1,@indexY);end

    def setIndex(x,y)
      pbPlayCursorSE() if @indexX!=-1 # Ignores first time
      x%=COLUMNS+1
      y%=ROWS+1
      # Small adjustment
      if @indexY==0 && x==0
        x = @indexX==1 ? COLUMNS : 1
      end
      if @indexX==0 && y==0
        y = @indexY==1 ? ROWS : 1
      end
      # Change index format
      if x==0 && @indexX!=0
        @sprite.setBitmap("Graphics/Pictures/Roulette/selectedcolor")
      end
      if y==0 && @indexY!=0
        @sprite.setBitmap("Graphics/Pictures/Roulette/selectedspecies")
      end
      if (y!=0 && @indexY<=0) || (x!=0 && @indexX<=0)
        @sprite.setBitmap("Graphics/Pictures/Roulette/selectedsingle")
      end
      @indexX = x
      @indexY = y
      refreshSpritePos
      resetframeCount
    end

    def refreshSpritePos(extraX=0)
      @sprite.x=@tableX-2+@indexX*48+extraX
      @sprite.x+=4 if @indexX==0
      @sprite.y=@tableY-2+@indexY*48
      @sprite.y+=4 if @indexY==0
    end

    def bentPositions
      if @indexX==0
        return TABLE_POSITIONS[@indexY-1]
      elsif @indexY==0
        return TABLE_POSITIONS.transpose[@indexX-1]
      else
        return [TABLE_POSITIONS[@indexY-1][@indexX-1]]
      end
    end

    def multiplier # Picks the multiplier value
      checkedPositions=[]
      if @indexX==0
        checkedPositions=@playedBalls[(@indexY-1)*COLUMNS,COLUMNS]
      elsif @indexY==0
        for i in 0...ROWS
          checkedPositions.push(@playedBalls[@indexX-1+i*COLUMNS])
        end
      else
        checkedPositions.push(@playedBalls[@indexX-1+(@indexY-1)*COLUMNS])
      end
      div=RouletteScreen.count(checkedPositions,false)
      result=0
      result=COLUMNS*ROWS/div if div!=0
      return result
    end
  end

  class RouletteObject
    attr_reader :roulette # Sprite
    attr_reader :balls # Sprite Array

    def initialize(roulette)
      @roulette=roulette
      @balls=[]
    end

    def addBall(sprite)
      sprite.x=roulette.x
      sprite.y=roulette.y
      sprite.visible=true
      sprite.angle=@roulette.angle-10
      balls.push(sprite)
    end

    def clearBalls
      for ball in @balls
        ball.visible=false
      end
      @balls.clear
    end

    # Redraws the bitmap with the height and the changed ox and oy where
    # the ball picture will be at the top to create the illusion that the
    # ball is spinning.
    # The lower the height, the lower the distance to the roulette center.
    def adjustBitmapBall(i,height)
      bitmapBall = Bitmap.new("Graphics/Pictures/Roulette/ball")
      @balls[i].bitmap=Bitmap.new(30,height)
      @balls[i].bitmap.blt(0,0,bitmapBall,bitmapBall.rect)
      @balls[i].ox=balls[i].bitmap.width/2
      @balls[i].oy=balls[i].bitmap.height
    end

    def x=(value)
      @roulette.x=value
      for ball in @balls
        ball.x=value
      end
    end

    def y=(value)
      @roulette.y=value
    end

    def sumAngle(value)
      @roulette.angle+=value
      for ball in @balls
        ball.angle+=value
      end
    end

    def update
      sumAngle(2)
    end
  end

  def startScene(wager, backgroundColor, usedIconColor)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @backgroundColor=backgroundColor
    @usedIconColor=usedIconColor
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["background"].bitmap.fill_rect(0,0,
      @sprites["background"].bitmap.width,
      @sprites["background"].bitmap.height, @backgroundColor
    )
    @sprites["roulette"]=IconSprite.new(0,0,@viewport)
    @sprites["roulette"].setBitmap("Graphics/Pictures/Roulette/roulette")
    @sprites["roulette"].ox=@sprites["roulette"].bitmap.width/2
    @sprites["roulette"].oy=@sprites["roulette"].bitmap.height/2
    @roulette=RouletteObject.new(@sprites["roulette"])
    @sprites["table"]=IconSprite.new(0,0,@viewport)
    @sprites["table"].setBitmap("Graphics/Pictures/Roulette/table")
    @sprites["multiplierbox"]=IconSprite.new(0,0,@viewport)
    @sprites["multiplierbox"].setBitmap(
      "Graphics/Pictures/Roulette/multiplierbox"
    )
    @sprites["multiplierbox"].z=1
    @multiplierBoxUnclampedX = @sprites["multiplierbox"].x
    @sprites["creditbox"]=IconSprite.new(0,0,@viewport)
    @sprites["creditbox"].setBitmap("Graphics/Pictures/Roulette/creditbox")
    @sprites["creditbox"].x=Graphics.width-@sprites["creditbox"].bitmap.width-6
    @sprites["creditbox"].y=6
    @sprites["creditbox"].z=1
    for i in 0...ROUNDS
      @sprites["ball#{i}"]=IconSprite.new(0,0,@viewport)
      @sprites["ball#{i}"].visible=false
      @sprites["balltable#{i}"]=IconSprite.new(0,0,@viewport)
      @sprites["balltable#{i}"].setBitmap("Graphics/Pictures/Roulette/ball")
      @sprites["balltable#{i}"].visible=false
      @sprites["ballicon#{i}"]=IconSprite.new(0,0,@viewport)
      @sprites["ballicon#{i}"].setBitmap("Graphics/Pictures/Roulette/ballicon")
      # Right to left
      @sprites["ballicon#{i}"].x=(@sprites["creditbox"].x-6+(ROUNDS-i-1)*16)
      @sprites["ballicon#{i}"].y=(
          @sprites["creditbox"].y+@sprites["creditbox"].bitmap.height+2
      )
    end
    @sprites["cursor"]=IconSprite.new(0,0,@viewport)
    @playedBalls=[]
    (COLUMNS*ROWS).times do
      @playedBalls.push(false)
    end
    @sprites["overlaycredits"]=BitmapSprite.new(
        Graphics.width,Graphics.height,@viewport
    )
    @sprites["overlaycredits"].z=2
    @sprites["overlaymultiplier"]=BitmapSprite.new(
        Graphics.width,Graphics.height,@viewport
    )
    @sprites["overlaymultiplier"].z=2
    pbSetSystemFont(@sprites["overlaycredits"].bitmap)
    pbSetSystemFont(@sprites["overlaymultiplier"].bitmap)
    @sprites["overlaycredits"].bitmap.font.bold=true
    @sprites["overlaymultiplier"].bitmap.font.bold=true
    @wager=wager
    @centralizeRoulette = false
    @movedDistance = 0
    @waitingMovement = false
    @degreesToSpin = 0
    @framesRemainingToBlink = 0
    @displayedCredits = RouletteBridge.coins
    @exit=false
    @tableBallPosArray = []
    refreshBottomElementsPos
    @cursor = Cursor.new(
      @sprites["cursor"],@playedBalls,@sprites["table"].x,@sprites["table"].y
    )
    drawCredits
    pbFadeInAndShow(@sprites) { update }
    displayMessage(
      _INTL("Place your wager with the arrows, then press the C key.")
    )
    drawMultiplier
  end

  def refreshBottomElementsPos
    @cursor.refreshSpritePos(@movedDistance) if @cursor
    # Roulette
    @roulette.x = [
      @sprites["roulette"].bitmap.width/2+4 + @movedDistance/2,
      (Graphics.width)/2 # @sprites["roulette"].bitmap.width+
    ].min
    @roulette.y = Graphics.height/2
    # Table
    @sprites["table"].x = (
      Graphics.width-@sprites["table"].bitmap.width-10 + @movedDistance
    )
    @sprites["table"].y=Graphics.height-@sprites["table"].bitmap.height-10
    for i in 0...@tableBallPosArray.size
      @sprites["balltable#{i}"].x = @tableBallPosArray[i][0] + @movedDistance
      @sprites["balltable#{i}"].y = @tableBallPosArray[i][1]
    end
    # Multiplier
    baseMultiplierBoxX = @sprites["table"].x-14
    @sprites["multiplierbox"].x = [
      baseMultiplierBoxX,
      Graphics.width-@sprites["multiplierbox"].bitmap.width-10
    ].min
    @sprites["multiplierbox"].y=@sprites["table"].y+6
    @sprites["overlaymultiplier"].x = (
      @movedDistance + @sprites["multiplierbox"].x - baseMultiplierBoxX
    )
  end

  def update
    pbUpdateSpriteHash(@sprites)
    @cursor.update
    @roulette.update
    if @displayedCredits < RouletteBridge.coins && Graphics.frame_count % 3 == 0
      @displayedCredits+=1
      drawCredits
    end
  end

  def drawMultiplier
    overlay=@sprites["overlaymultiplier"].bitmap
    overlay.clear
    multiplier=@cursor.multiplier
    return if multiplier==0
    baseColor = {
      6 => Color.new(0xf7,0xc7,0x0e), # Yellow
      4 => Color.new(0xc1,0xa1,0xf4), # Purple
      3 => Color.new(0xf8,0xf8,0xf8), # White
    }.fetch(multiplier, Color.new(0xf8,0xa8,0x88)) # Default Red
    textPosition=[multiplier.to_s,
       @sprites["multiplierbox"].x+@sprites["multiplierbox"].bitmap.width-8,
       @sprites["multiplierbox"].y+6,true,baseColor,Color.new(0x60,0x60,0x70)
    ]
    RouletteBridge.drawTextPositions(overlay,[textPosition])
  end

  def drawCredits
    overlay=@sprites["overlaycredits"].bitmap
    overlay.clear
    textPosition=[@displayedCredits.to_s,
        @sprites["creditbox"].x+@sprites["creditbox"].bitmap.width-26,
        @sprites["creditbox"].y+32,
        true,Color.new(248,248,248),Color.new(0,0,0)
    ]
    RouletteBridge.drawTextPositions(overlay,[textPosition])
  end

  # Adds the coins and updates the credit box. Return false if coins+number<0
  def addCredits(number, instant=true)
    return false if RouletteBridge.coins+number<0
    RouletteBridge.coins = [
      RouletteBridge.maxCoins, RouletteBridge.coins+number
    ].min
    if instant
      @displayedCredits = RouletteBridge.coins
      drawCredits
    end
    return true
  end

  def displayMessage(message)
    RouletteBridge.message(message){update}
  end

  def confirmMessage(message)
    return RouletteBridge.confirmMessage(message){update}
  end

  def main
    loop do
      Graphics.update
      Input.update
      self.update
      if @framesRemainingToBlink>0
        blink
      elsif @waitingMovement
        movePictures
      elsif @degreesToSpin>0
        spinRoulette
      else
        if Input.trigger?(Input::C)
          if @cursor.multiplier!=0
            pbSEPlay(RouletteBridge.getAudioName("Slots coin"))
            addCredits(-@wager)
            @centralizeRoulette = !@centralizeRoulette
            @waitingMovement = true
          else
            pbPlayBuzzerSE()
          end
        end
        break if @exit
        if Input.trigger?(Input::UP);   @cursor.moveUp;   drawMultiplier;end
        if Input.trigger?(Input::DOWN); @cursor.moveDown; drawMultiplier;end
        if Input.trigger?(Input::LEFT); @cursor.moveLeft; drawMultiplier;end
        if Input.trigger?(Input::RIGHT);@cursor.moveRight;drawMultiplier;end
      end
    end
  end

  def movePictures
    speed = 12
    speed *= - 1 if !@centralizeRoulette # Reverse the way
    @movedDistance+=speed
    refreshBottomElementsPos
    # The conditions for finish centralize and decentralize
    if (
      @centralizeRoulette && Graphics.width<(@sprites["table"].x) ||
      !@centralizeRoulette && @movedDistance==0
    )
      @waitingMovement = false
      @centralizeRoulette ? startSpin : endSpin
    end
  end

  SPINS=[60*30,36*20,30*10,20*3] # Spins quantity and tiers

  def startSpin
    i=RouletteScreen.count(@playedBalls,true)
    @sprites["ballicon#{i}"].setBitmap(
      "Graphics/Pictures/Roulette/ballusedicon"
    )
    @sprites["ballicon#{i}"].color=@usedIconColor
    @result=-1
    loop do
      @result = rand(@playedBalls.size)
      break if !@playedBalls[@result]
    end
    @roulette.addBall(@sprites["ball#{i}"])
    @roulette.adjustBitmapBall(i,148)
    @variableDegrees=10*3*TABLE_POSITIONS.flatten[@result]+SPINS[3]
    @degreesToSpin=SPINS[0]+SPINS[1]+SPINS[2]+@variableDegrees
    pbSEPlay(RouletteBridge.getAudioName("Roulette Ball"))
  end

  def spinRoulette
    i=RouletteScreen.count(@playedBalls,true)
    # Spins tier speeds
    if @degreesToSpin>SPINS[1]+SPINS[2]+@variableDegrees
      degrees=30
    elsif @degreesToSpin>SPINS[2]+@variableDegrees
      degrees=20
    elsif @degreesToSpin>@variableDegrees
      degrees=10
    elsif @degreesToSpin>0
      degrees=3
    end
    @sprites["ball#{i}"].angle-=degrees
    @degreesToSpin-=degrees
    # Makes the ball more near of the center after some spins
    height=0
    if @degreesToSpin==0
      height=74
    elsif @degreesToSpin==@variableDegrees
      height=88
    elsif @degreesToSpin==SPINS[2]/2+@variableDegrees
      height=98
    elsif @degreesToSpin==SPINS[2]+@variableDegrees
      height=108
    elsif @degreesToSpin==SPINS[1]/2+SPINS[2]+@variableDegrees
      height=118
    elsif @degreesToSpin==SPINS[1]+SPINS[2]+@variableDegrees
      height=128
    end
    @roulette.adjustBitmapBall(i,height) if height!=0
    if @degreesToSpin==SPINS[2]+@variableDegrees # Play ending SFX
      pbSEStop
      pbSEPlay(RouletteBridge.getAudioName("Roulette Ball End"))
    end
    if @degreesToSpin==0 # End
      pbSEPlay(RouletteBridge.getAudioName("Battle ball drop"))
      @centralizeRoulette = !@centralizeRoulette
      @waitingMovement = true
    end
  end

  BLINK_TIMES = 4
  FRAMES_PER_BLINK = 4
  WAIT_AFTER_BLINK = 8
  BLINK_LAST_WAIT = 2

  def endSpin
    @tableBallPosArray.push([
      6+@sprites["table"].x+(@result%COLUMNS+1)*48,
      6+@sprites["table"].y+(@result/COLUMNS+1)*48
    ])
    @framesRemainingToBlink = (BLINK_TIMES+BLINK_LAST_WAIT)*FRAMES_PER_BLINK*2
    refreshBottomElementsPos
  end

  def blink
    i=RouletteScreen.count(@playedBalls,true)
    @framesRemainingToBlink-=1
    lastWait = @framesRemainingToBlink / FRAMES_PER_BLINK < BLINK_LAST_WAIT*2
    @sprites["balltable#{i}"].visible = (
      @framesRemainingToBlink / FRAMES_PER_BLINK % 2 == 0 || lastWait
    )
    processResults if @framesRemainingToBlink==0
  end

  def processResults
    wins = @cursor.bentPositions.include?(TABLE_POSITIONS.flatten[@result])
    if wins
      multiplier = @cursor.multiplier
      if multiplier==12
        displayMessage(_INTL(
          "\\me[{1}]Jackpot!\\wtnp[50]",
          RouletteBridge.getAudioName("Slots big win")
        ))
      else
        displayMessage(_INTL(
          "\\me[{1}]It's a hit!\\wtnp[30]",
          RouletteBridge.getAudioName("Slots win")
        ))
      end
      addCredits(@wager*multiplier, false)
      displayMessage(_INTL("You've won {1} Coins!",@wager*multiplier))
    else
      pbPlayBuzzerSE()
      displayMessage(_INTL("Nothing doing!"))
    end
    @playedBalls[@result]=true
    if RouletteScreen.count(@playedBalls,true)==(ROUNDS-1) # Clear
      displayMessage(_INTL("The Roulette board will be cleared."))
      @roulette.clearBalls
      @playedBalls.clear
      @tableBallPosArray.clear
      (COLUMNS*ROWS).times do
        @playedBalls.push(false)
      end
      for index in 0...ROUNDS
        @sprites["balltable#{index}"].visible=false
        @sprites["ballicon#{index}"].setBitmap(
            "Graphics/Pictures/Roulette/ballicon"
        )
        @sprites["ballicon#{index}"].color=Color.new(0,0,0,0)
      end
    end
    drawMultiplier
    if confirmMessage(_INTL("Keep playing?"))
      if RouletteBridge.coins<@wager
        displayMessage(_INTL("You don't have enough Coins to play!"))
        @exit=true
      end
    else
      @exit=true
    end
  end

  def endScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class RouletteScreen
  RED   = [Color.new(0xc0,0x20,0x50), Color.new(0xf8,0x98,0xa0)]
  GREEN = [Color.new(0x51,0x96,0x31), Color.new(0x84,0xdd,0x57)]
  BLUE  = [Color.new(0x20,0x50,0xc0), Color.new(0x98,0xa0,0xf8)]

  # Added since Ruby 1.8 Array class doesn't have count
  def self.count(array, value)
    ret=0
    for element in array
      ret+=1 if element==value
    end
    return ret
  end

  def initialize(scene)
    @scene=scene
  end

  def startScreen(wager, backgroundAndIconColor)
    backgroundAndIconColor ||= RED
    @scene.startScene(
      wager,backgroundAndIconColor[0],backgroundAndIconColor[1]
    )
    @scene.main
    @scene.endScene
  end
end

def roulette(wager=1, backgroundAndIconColor=nil)
  if !RouletteBridge.hasCoinCase?
    RouletteBridge.message(_INTL("It's a Roulette."))
  elsif RouletteBridge.confirmMessage(_INTL(
    "\\CNThe minimum wanger at this table is {1}. Do you want to play?", wager
  ))
    if RouletteBridge.coins<wager
      RouletteBridge.message(_INTL("You don't have enough Coins to play!"))
    elsif RouletteBridge.coins==RouletteBridge.maxCoins
      RouletteBridge.message(_INTL("Your Coin Case is full!"))
    else
      pbFadeOutIn(99999){
        scene=RouletteScene.new
        screen=RouletteScreen.new(scene)
        screen.startScreen(wager, backgroundAndIconColor)
      }
    end
  end
end

# Essentials multiversion layer
module RouletteBridge
  if defined?(Essentials)
    MAJOR_VERSION = Essentials::VERSION.split(".")[0].to_i
  elsif defined?(ESSENTIALS_VERSION)
    MAJOR_VERSION = ESSENTIALS_VERSION.split(".")[0].to_i
  elsif defined?(ESSENTIALSVERSION)
    MAJOR_VERSION = ESSENTIALSVERSION.split(".")[0].to_i
  else
    MAJOR_VERSION = 0
  end

  @@audioNameHash = nil

  module_function

  def message(string, &block)
    return Kernel.pbMessage(string, &block) if MAJOR_VERSION < 20
    return pbMessage(string, &block)
  end

  def confirmMessage(string, &block)
    return Kernel.pbConfirmMessage(string, &block) if MAJOR_VERSION < 20
    return pbConfirmMessage(string, &block)
  end

  def drawTextPositions(bitmap,textpos)
    if MAJOR_VERSION < 20
      for singleTextPos in textpos
        singleTextPos[2] -= MAJOR_VERSION==19 ? 12 : 6
      end
    end
    return pbDrawTextPositions(bitmap,textpos)
  end

  def coinHolder
    return case MAJOR_VERSION
      when 0..18; $PokemonGlobal
      when 19;    $Trainer
      else        $player
    end
  end

  def coins
    return coinHolder.coins
  end

  def coins=(value)
    coinHolder.coins = value
  end

  def maxCoins
    return case MAJOR_VERSION
      when 0..17; MAXCOINS
      when 18;    MAX_COINS
      else        Settings::MAX_COINS
    end
  end

  def hasCoinCase?
    return case MAJOR_VERSION
      when 0..18; $PokemonBag.pbQuantity(PBItems::COINCASE) > 0
      when 19;    $PokemonBag.pbHasItem?(:COINCASE)
      else        $bag.has?(:COINCASE)
    end
  end

  def getAudioName(baseName)
    if !@@audioNameHash
      if MAJOR_VERSION < 17
        @@audioNameHash = {
          "Battle ball drop" => "balldrop"   ,
          "Slots coin"       => "SlotsCoin"  ,
          "Slots win"        => "SlotsWin"   ,
          "Slots big win"    => "SlotsBigWin",
        }
      else
        @@audioNameHash = {}
      end
    end
    return @@audioNameHash.fetch(baseName, baseName)
  end
end
