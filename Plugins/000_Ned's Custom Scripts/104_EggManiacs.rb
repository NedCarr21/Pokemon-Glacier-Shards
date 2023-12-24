def gseggManiac(price1,price2,price3,pkmn1,pkmn2,pkmn3,pkmn4,pkmn5,pkmn6,pkmn7,pkmn8,pkmn9)

  pbMessage(_INTL("Egg Maniac: Hey there fellow traveler!"))
  pbMessage(_INTL("\\GI'm an egg maniac, I love to breed eggs, and sell them off to passerby travellers."))
  if pbConfirmMessage(_INTL("\\GWould you like to buy an egg from me?"))
      cmds = [
        _INTL("${1}", price1),
        _INTL("${1}", price2),
        _INTL("${1}", price3),
        _INTL("None")
      ]
      egg = pbMessage(_INTL("\\GThat's grand!\nHere's what I have to offer."), cmds, 3)
      pbWait(4)
      case egg
        when 0 #price1
          pbWait(4)
          case rand(3)
            when 0; eggpkmn = pkmn1
            when 1; eggpkmn = pkmn2
            when 2; eggpkmn = pkmn3
          end
          eggpkmn = gsRandompkmn if $game_switches[61]
          eggpkmn.ability = gsRandomabil if $game_switches[61]

          if (pbGenerateEgg(eggpkmn))
            $player.money-=price1
            pbMessage(_INTL("Enjoy your egg, I have many more so come back whenever."))
          else
            pbMessage(_INTL("You have no room to store the Egg..."))
          end
        when 1 #price2
          pbWait(4)
          case rand(3)
            when 0; eggpkmn = pkmn4
            when 1; eggpkmn = pkmn5
            when 2; eggpkmn = pkmn6
          end
          eggpkmn = gsRandompkmn if $game_switches[61]
          eggpkmn.ability = gsRandomabil if $game_switches[61]

          if (pbGenerateEgg(eggpkmn))
            $player.money-=price2
            pbMessage(_INTL("Enjoy your egg, I have many more so come back whenever."))
          else
            pbMessage(_INTL("You have no room to store the Egg..."))
          end
        when 2 #price3
          pbWait(4)
          case rand(3)
            when 0; eggpkmn = pkmn7
            when 1; eggpkmn = pkmn8
            when 2; eggpkmn = pkmn9
          end
          eggpkmn = gsRandompkmn if $game_switches[61]
          eggpkmn.ability = gsRandomabil if $game_switches[61]

          if (pbGenerateEgg(eggpkmn))
            $player.money-=price3
            pbMessage(_INTL("Enjoy your egg, I have many more so come back whenever."))
          else
            pbMessage(_INTL("You have no room to store the Egg..."))
          end
        when 3
          pbMessage(_INTL("Ahh, I see then, all good, enjoy your travels!"))
      end # end of case egg
  else
    pbMessage(_INTL("Ahh, I see then, all good, enjoy your travels!"))
  end # end of if pbConfirmMessage
end # end of def
