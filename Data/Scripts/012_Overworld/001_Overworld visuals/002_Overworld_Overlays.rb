#===============================================================================
# Location signpost
#===============================================================================
class LocationWindow
  APPEAR_TIME = 0.4   # In seconds; is also the disappear time
  LINGER_TIME = 1.6   # In seconds; time during which self is fully visible

  def initialize(name)
    @window = Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name, Graphics.width)
    @window.x        = 0
    @window.y        = -@window.height
    @window.viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @window.viewport.z = 99999
    @currentmap = $game_map.map_id
    @timer_start = System.uptime
  end

  def disposed?
    return @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      @window.dispose
      return
    end
    if System.uptime - @timer_start >= APPEAR_TIME + LINGER_TIME
      @window.y = lerp(0, -@window.height, APPEAR_TIME, @timer_start + APPEAR_TIME + LINGER_TIME, System.uptime)
      @window.dispose if @window.y + @window.height <= 0
    else
      @window.y = lerp(-@window.height, 0, APPEAR_TIME, @timer_start, System.uptime)
    end
  end
end

#===============================================================================
# Visibility circle in dark maps
#===============================================================================
class DarknessSprite < Sprite
  attr_reader :radius

  def initialize(viewport = nil)
    super(viewport)
    @darkness = Bitmap.new(Graphics.width, Graphics.height)
    @radius = radiusMin
    self.bitmap = @darkness
    self.z      = 99998
    refresh
  end

  def dispose
    @darkness.dispose
    super
  end

  def radiusMin; return 64;  end   # Before using Flash
  def radiusMax; return 176; end   # After using Flash

  def radius=(value)
    @radius = value.round
    refresh
  end

  def refresh
    @darkness.fill_rect(0, 0, Graphics.width, Graphics.height, Color.black)
    cx = Graphics.width / 2
    cy = Graphics.height / 2
    cradius = @radius
    numfades = 5
    (1..numfades).each do |i|
      (cx - cradius..cx + cradius).each do |j|
        diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
        diff = Math.sqrt(diff2)
        @darkness.fill_rect(j, cy - diff, 1, diff * 2, Color.new(0, 0, 0, 255.0 * (numfades - i) / numfades))
      end
      cradius = (cradius * 0.9).floor
    end
  end
end

#===============================================================================
# Light effects
#===============================================================================
class LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    @light = IconSprite.new(0, 0, viewport)
    if !nil_or_empty?(filename) && pbResolveBitmap("Graphics/Pictures/" + filename)
      @light.setBitmap("Graphics/Pictures/" + filename)
    else
      @light.setBitmap("Graphics/Pictures/LE")
    end
    @light.z = 1000
    @event = event
    @map = (map) ? map : $game_map
    @disposed = false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map = nil
    @event = nil
    @disposed = true
  end

  def update
    @light.update
  end
end

#===============================================================================
#
#===============================================================================
class LightEffect_Lamp < LightEffect
  def initialize(event, viewport = nil, map = nil)
    lamp = AnimatedBitmap.new("Graphics/Pictures/LE")
    @light = Sprite.new(viewport)
    @light.bitmap = Bitmap.new(128, 64)
    src_rect = Rect.new(0, 0, 64, 64)
    @light.bitmap.blt(0, 0, lamp.bitmap, src_rect)
    @light.bitmap.blt(20, 0, lamp.bitmap, src_rect)
    @light.visible = true
    @light.z       = 1000
    lamp.dispose
    @map = (map) ? map : $game_map
    @event = event
  end
end

#===============================================================================
#
#===============================================================================
class LightEffect_Basic < LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    super
    @light.ox = @light.bitmap.width / 2
    @light.oy = @light.bitmap.height / 2
    @light.opacity = 100
  end

  def update
    return if !@light || !@event
    super
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x      = ScreenPosHelper.pbScreenX(@event)
      @light.y      = ScreenPosHelper.pbScreenY(@event) - (@event.height * Game_Map::TILE_HEIGHT / 2)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
      @light.zoom_y = @light.zoom_x
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y - (Game_Map::TILE_HEIGHT / 2)
    end
    @light.tone = $game_screen.tone
  end
end

#===============================================================================
#
#===============================================================================
class LightEffect_DayNight < LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    super
    @light.ox = @light.bitmap.width / 2
    @light.oy = @light.bitmap.height / 2
  end

  def update
    return if !@light || !@event
    super
    shade = PBDayNight.getShade
    if shade >= 144   # If light enough, call it fully day
      shade = 255
    elsif shade <= 64   # If dark enough, call it fully night
      shade = 0
    else
      shade = 255 - (255 * (144 - shade) / (144 - 64))
    end
    @light.opacity = 255 - shade
    if @light.opacity > 0
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x      = ScreenPosHelper.pbScreenX(@event)
        @light.y      = ScreenPosHelper.pbScreenY(@event) - (@event.height * Game_Map::TILE_HEIGHT / 2)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @light.zoom_y = ScreenPosHelper.pbScreenZoomY(@event)
      else
        @light.x = @event.screen_x
        @light.y = @event.screen_y - (Game_Map::TILE_HEIGHT / 2)
      end
      @light.tone.set($game_screen.tone.red,
                      $game_screen.tone.green,
                      $game_screen.tone.blue,
                      $game_screen.tone.gray)
    end
  end
end

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_new_spriteset_map, :add_light_effects,
  proc { |spriteset, viewport|
    map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
    map.events.each_key do |i|
      if map.events[i].name[/^outdoorlight\((\w+)\)$/i]
        filename = $~[1].to_s
        spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map, filename))
      elsif map.events[i].name[/^outdoorlight$/i]
        spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map))
      elsif map.events[i].name[/^light\((\w+)\)$/i]
        filename = $~[1].to_s
        spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map, filename))
      elsif map.events[i].name[/^light$/i]
        spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map))
      end
    end
  }
)
=begin
  @sprites["t_left"]
  @sprites["t_right"]
  @sprites["b_left"]
  @sprites["b_right"]
=end
class RemovableEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)

    @sprites = {}
    @update = 0

    @event = event
    @map = $game_map
    @disposed = false

    @sprites["t_left"] = IconSprite.new(0, 0, viewport)
    @sprites["t_right"] = IconSprite.new(0, 0, viewport)
    @sprites["b_left"] = IconSprite.new(0, 0, viewport)
    @sprites["b_right"] = IconSprite.new(0, 0, viewport)

    @sprites["t_left"].setBitmap("Graphics/Pictures/remove_ow_tl")
    @sprites["t_right"].setBitmap("Graphics/Pictures/remove_ow_tr")
    @sprites["b_left"].setBitmap("Graphics/Pictures/remove_ow_bl")
    @sprites["b_right"].setBitmap("Graphics/Pictures/remove_ow_br")

    @sprites["t_left"].z = 500
    @sprites["t_right"].z = 500
    @sprites["b_left"].z = 500
    @sprites["b_right"].z = 500

    @sprites["t_left"].x = @event.x * 16
    @sprites["t_left"].y = @event.y * 16
    @sprites["t_right"].x = @event.width * 16
    @sprites["t_right"].y = @event.y * 16
    @sprites["b_left"].x = @event.x * 16
    @sprites["b_left"].y = @event.height * 16
    @sprites["b_right"].x = @event.width * 16
    @sprites["b_right"].y = @event.height * 16

  end

  def disposed?
    return @disposed
  end

  def dispose
    @sprites["t_left"].dispose
    @sprites["t_right"].dispose
    @sprites["b_left"].dispose
    @sprites["b_right"].dispose
    @map = nil
    @event = nil
    @disposed = true
  end

  def update
    @update += 1
    if @update == 60
      @sprites["t_left"].x -= 2
      @sprites["t_left"].y -= 2
      @sprites["t_right"].x += 2
      @sprites["t_right"].y -= 2
      @sprites["b_left"].x -= 2
      @sprites["b_left"].y += 2
      @sprites["b_right"].x += 2
      @sprites["b_right"].y += 2
    elsif @update >= 120
      @sprites["t_left"].x += 2
      @sprites["t_left"].y += 2
      @sprites["t_right"].x -= 2
      @sprites["t_right"].y += 2
      @sprites["b_left"].x += 2
      @sprites["b_left"].y -= 2
      @sprites["b_right"].x -= 2
      @sprites["b_right"].y -= 2
      @update = 0
    end
  end
end

EventHandlers.add(:on_new_spriteset_map, :add_removable_effect,
  proc { |spriteset, viewport|
    map = $game_map   # Map associated with the spriteset (not necessarily the current map)
    map.events.each_key do |i|
      if map.events[i].name[/removable_overworld$/i]
        filename = $~[1].to_s
        spriteset.addUserSprite(RemovableEffect.new(map.events[i], viewport, map, filename))
      end
    end
  }
)
