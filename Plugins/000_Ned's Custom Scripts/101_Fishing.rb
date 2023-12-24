def randFishingItem
  case rand(100)
    when 0..9;   pbReceiveItem(:HEARTSCALE,1)        # 10/100
    when 10..49; pbReceiveItem(:MUD,1)               # 40/100
    when 50..65; pbReceiveItem(:PEARL,1)             # 16/100
    when 66..78; pbReceiveItem(:BIGPEARL,1)          # 13/100
    when 79..88; pbReceiveItem(:PEARLSTRING,1)       # 10/100
    when 89;     pbReceiveItem(:LUCKYEGG,1)          # 1/100
    when 90..95; pbReceiveItem(:SPECIALTYBAIT,1)     # 6/100
    when 96..97; pbReceiveItem(:RELICCOPPER,1)       # 2/100
    when 98;     pbReceiveItem(:RELICSILVER,1)       # 1/100
    when 99;     pbReceiveItem(:RELICGOLD,1)         # 1/100
  end
end

BASICITEMCHANCE = 8 # 1/8 chance for item
SWEETITEMCHANCE = 8 # 1/8 chance for item
SPECIALTYITEMCHANCE = 8 # 1/8 chance for item

STYLES = [
  [:MAGIKARP,:CHINCHOU,:FEEBAS,:LOTAD], # style = 0
  [:MAGIKARP,:SLOWPOKE,:SLOWPOKE_1,:CORSOLA], # style = 1
  [:MAGIKARP,:CHINCHOU,:CORSOLA_1,:FEEBAS], # style = 2
  [:MAGIKARP,:STUNFISK,:HORSEA,:LOTAD], # style = 3
  [:CHINCHOU,:HORSEA,:CORSOLA,:CORSOLA_1], # style = 4
  [:FEEBAS,:SLOWPOKE,:SLOWPOKE_1,:CORSOLA,:CORSOLA_1,:STUNFISK,:HORSEA,:LOTAD] # style = 5
]

def baitFishing(style=rand(6),minlvl=3,maxlvl=5) # the number here must be equal to the amount of arrays in the STYLES array +1
  bait = 0
  pbMessage(_INTL("There seems to be some activity in the water."))
  if pbConfirmMessage(_INTL("Do you want to toss in some bait?"))
    if ($bag.has?(:BASICBAIT) || $bag.has?(:SWEETBAIT) || $bag.has?(:SPECIALTYBAIT))
      cmds = [
        _INTL("Basic Bait"),
        _INTL("Sweet Bait"),
        _INTL("Specialty Bait"),
        _INTL("None")
      ]
      bait = pbMessage(_INTL("Which bait would you like to use?"), cmds, 3)
      pbWait(4)
      pbMessage(_INTL("\\wtnp[4].\\wt[10].\\wt[10]."))
      pbWait(4)
      pkmn = Pokemon.new(STYLES[style].sample, rand(minlvl..maxlvl))
      case bait
        when 0 # Basic Bait
          if rand(0..BASICITEMCHANCE) == 1
            randFishingItem # gives a random item
          else
            pkmn.calc_stats
            WildBattle.start(pkmn)
          end
        when 1 # Sweet Bait
          if rand(0..SWEETITEMCHANCE) == 1
            randFishingItem # gives a random item
          else
            pkmn.ability_index = 2 if rand(10) == 1
            pkmn.calc_stats
            WildBattle.start(pkmn)
          end
        when 2 # Specialty Bait
          if rand(0..SPECIALTYITEMCHANCE) == 1
            randFishingItem # gives a random item
          else
            pkmn.ability_index = 2 if rand(10) == 1
            pkmn.shiny = true if rand(100) == 1
            pkmn.calc_stats
            WildBattle.start(pkmn)
          end
      end #cast bait end
    else
      pbMessage(_INTL("You don't have any bait."))
    end # $bag.has? end
  end #pbConfirmMessage end
end #def end
