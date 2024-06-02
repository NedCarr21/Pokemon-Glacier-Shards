

class PokeNav_Scene

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @sprites["bg"].ox = 0 if @sprites["bg"].ox == -42 && @sprites["bg"].visible == true
    @sprites["bg"].oy = 0 if @sprites["bg"].ox == -50 && @sprites["bg"].visible == true
    @sprites["bg"].ox -= 1 if @sprites["bg"].visible == true
    @sprites["bg"].oy -= 1 if @sprites["bg"].visible == true

    @sprites["sel"].x = (128 * (@nav_selected - 1) + 72)
    @sprites["sel"].x -= 384 if @nav_selected > 3
    @sprites["sel"].y = 96 if @nav_selected < 4
    @sprites["sel"].y = 204 if @nav_selected > 3

    time = pbGetTimeNow
    hour = time.hour
    minute = time.min

    drawTime

    map = $game_map.map_id

    case $game_screen.weather_type
        when :Rain,:HeavyRain
          @sprites["weather"].setBitmap("Graphics/Pictures/PokeNav/weather_rain")
        when :Snow,:Blizzard
          @sprites["weather"].setBitmap("Graphics/Pictures/PokeNav/weather_snow")
      else
        @sprites["weather"].setBitmap("Graphics/Pictures/PokeNav/weather_sun")
    end
  end

  def pbStartScene()
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "Summary/bg", @viewport)
    @sprites["bg"].z = -99999

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)

    @sprites["base"] = IconSprite.new(0, 0, @viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/PokeNav/base")
    @sprites["base"].z = 0

    @sprites["dex"] = IconSprite.new(0, 0, @viewport)
    @sprites["dex"].setBitmap("Graphics/Pictures/PokeNav/nil_icon")
    @sprites["dex"].setBitmap("Graphics/Pictures/PokeNav/dex_icon") if $player.has_poke_nav_pokedex
    @sprites["dex"].x = 72
    @sprites["dex"].y = 96
    @sprites["dex"].z = 1

    @sprites["map"] = IconSprite.new(0, 0, @viewport)
    @sprites["map"].setBitmap("Graphics/Pictures/PokeNav/nil_icon")
    @sprites["map"].setBitmap("Graphics/Pictures/PokeNav/map_icon") if $player.has_poke_nav_map
    @sprites["map"].x = 200
    @sprites["map"].y = 96
    @sprites["map"].z = 1

    @sprites["nav"] = IconSprite.new(0, 0, @viewport)
    @sprites["nav"].setBitmap("Graphics/Pictures/PokeNav/nil_icon")
    @sprites["nav"].setBitmap("Graphics/Pictures/PokeNav/nav_icon") if $player.has_poke_nav_dex_nav
    @sprites["nav"].x = 328
    @sprites["nav"].y = 96
    @sprites["nav"].z = 1

    @sprites["quests"] = IconSprite.new(0, 0, @viewport)
    @sprites["quests"].setBitmap("Graphics/Pictures/PokeNav/nil_icon")
    @sprites["quests"].setBitmap("Graphics/Pictures/PokeNav/quest_icon") if $player.has_poke_nav_quests
    @sprites["quests"].x = 72
    @sprites["quests"].y = 204
    @sprites["quests"].z = 1

    @sprites["online"] = IconSprite.new(0, 0, @viewport)
    @sprites["online"].setBitmap("Graphics/Pictures/PokeNav/nil_icon")
    @sprites["online"].setBitmap("Graphics/Pictures/PokeNav/online_icon") if $player.has_poke_nav_online
    @sprites["online"].x = 200
    @sprites["online"].y = 204
    @sprites["online"].z = 1

    @sprites["wonder"] = IconSprite.new(0, 0, @viewport)
    @sprites["wonder"].setBitmap("Graphics/Pictures/PokeNav/nil_icon")
    @sprites["wonder"].setBitmap("Graphics/Pictures/PokeNav/wonder_icon") if $player.has_poke_nav_wonder
    @sprites["wonder"].x = 328
    @sprites["wonder"].y = 204
    @sprites["wonder"].z = 1

    @sprites["weather"] = IconSprite.new(0, 0, @viewport)
    @sprites["weather"].setBitmap("Graphics/Pictures/PokeNav/weather_sun")
    @sprites["weather"].x = 12
    @sprites["weather"].y = 304
    @sprites["weather"].z = 1

    @nav_selected = 1

    @sprites["sel"] = IconSprite.new(0, 0, @viewport)
    @sprites["sel"].setBitmap("Graphics/Pictures/PokeNav/select")
    @sprites["sel"].z = 2

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if(Input.trigger?(Input::ACTION) || Input.trigger?(Input::USE))
        pbPlayDecisionSE
          # Pokedex ----------------------------------------------------------------------
          if(@nav_selected == 1 && $player.has_poke_nav_pokedex)
            pbFadeOutIn {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
            }
          end
          # Town Map ---------------------------------------------------------------------
          if(@nav_selected == 2 && $player.has_poke_nav_map)
            pbFadeOutIn {
              scene = PokemonRegionMap_Scene.new(-1, false)
              screen = PokemonRegionMapScreen.new(scene)
              ret = screen.pbStartScreen
              $game_temp.fly_destination = ret if ret
              next 99999 if ret   # Ugly hack to make Bag scene not reappear if flying
            }
          end
          # Dex Nav ----------------------------------------------------------------------
          if(@nav_selected == 3 && $player.has_poke_nav_dex_nav)
            place = $game_map.map_id
            range = []
            pbMessage(_INTL("Searching for nearby Pokémon..."))
            Kernel.echo("Generating Selected Tile...\n")
            pbWait(12)

            x_range = [[$game_player.x - 16, 0].max, [$game_player.x + 16, $game_map.width].min]
            y_range = [[$game_player.y - 16, 0].max, [$game_player.y + 16, $game_map.height].min]

            for x in x_range[0]..x_range[1]
              for y in y_range[0]..y_range[1]
                terrain_tag = $game_map.terrain_tag(x, y)
                $dexnav_encounter = $PokemonEncounters.choose_wild_pokemon(:DexNav)
                if((terrain_tag.id == :Grass || terrain_tag.id == :TallGrass))
                  range.push([x,y])
                end
              end
            end

            if((rand(10)>1) && ($dexnav_encounter != nil) && (range != []))
              selected_tile = range.random
              $dexnav_x = selected_tile[0]
              $dexnav_y = selected_tile[1]

              Kernel.echo("Selected tile is x:" + $dexnav_x.to_s + ", y:" + $dexnav_y.to_s + "...\n")

              # create effect on tile
              $scene.spriteset.addUserAnimation(22, $dexnav_x, $dexnav_y)
              break
            else
              pbMessage(_INTL("No Pokémon was found..."))
            end
          end
          # Quests -----------------------------------------------------------------------
          if(@nav_selected == 4 && $player.has_poke_nav_quests)
            pbFadeOutIn {
              scene = QuestList_Scene.new
              screen = QuestList_Screen.new(scene)
              screen.pbStartScreen
            }
          end
          # Online -----------------------------------------------------------------------
          if(@nav_selected == 5 && $player.has_poke_nav_online)
            pbCableClub
          end
          # Wonder Trade -----------------------------------------------------------------
          if(@nav_selected == 6 && $player.has_poke_nav_wonder)
            pbWonderTrade
          end
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::UP)
        @nav_selected -= 3
        @nav_selected += 6 if @nav_selected < 1
      elsif Input.trigger?(Input::DOWN)
        @nav_selected += 3
        @nav_selected -= 6 if @nav_selected > 6
      elsif Input.trigger?(Input::LEFT)
        @nav_selected += 3 if @nav_selected == 4
        @nav_selected += 3 if @nav_selected == 1
        @nav_selected -= 1
      elsif Input.trigger?(Input::RIGHT)
        @nav_selected -= 3 if @nav_selected == 3
        @nav_selected -= 3 if @nav_selected == 6
        @nav_selected += 1
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def drawTime

    overlay = @sprites["overlay"].bitmap
    base   = Color.new(224, 232, 232)
    shadow = Color.new(64, 64, 64)

    textpos = [
      [pbGetTimeNow.hour.to_s, 72, 318, 2, base, shadow, true],
      [pbGetTimeNow.min.to_s, 100, 318, 2, base, shadow, true]
    ]

      pbDrawTextPositions(overlay, textpos)

  end

end

class PokeNav_Screen
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

GameData::EncounterType.register({
  :id => :DexNav,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [33, 33, 33],
})

EventHandlers.add(:on_player_step_taken, :dex_nav_create,
    proc {
      if ($game_player.x == $dexnav_x) && ($game_player.y == $dexnav_y)
        Kernel.echo("Standing on tile...")

        $game_temp.force_single_battle


        pkmn = Pokemon.new($dexnav_encounter[0], $dexnav_encounter[1])
        pkmn.shiny = true if (rand(65536/Settings::SHINY_POKEMON_CHANCE) < 4)

        WildBattle.start(pkmn)

        $dexnav_x = -1
        $dexnav_y = -1
      end
})

EventHandlers.add(:on_enter_map, :reset_dex_nav,
  proc {
    $dexnav_x = -1
    $dexnav_y = -1
  }
)
