def checkCode

  codeBank = [
  "HIPPY","VORTEX","FISHHEAD","NED",
  "EASTER***","HALLOWEEN***","CHRISTMAS***",
  "V0.9", "TITLENAME",
  "UNKNOWNGRASS","UNKNOWNFIRE","UNKNOWNWATER"
  ]

  if !($usedCodes.is_a?(Array))
    $usedCodes = Array.new
  end

  code = pbEnterText(_INTL("Enter a code."),0,16,"")

  if codeBank.include?(code.upcase)

      if $usedCodes.include?(code.upcase)
        pbMessage(_INTL("You have already redeemed this code."))
      else
        pbMessage(_INTL("A successful Code!"))

        case (code.upcase)
          when "NED"; pkmn = Pokemon.new(:MUDKIP,5)
            pkmn.owner.name = "Ned"
            pkmn.shiny = true
          when "HIPPY"; pkmn = Pokemon.new(:ZORUA,5)
            pkmn.owner.name = "Hippy"
            pkmn.shiny = true
          when "VORTEX"; pkmn = Pokemon.new(:RALTS,5)
            pkmn.owner.name = "Vortex"
            pkmn.shiny = true
            pkmn.makeFemale
          when "FISHHEAD"; pkmn = Pokemon.new(:APPLIN,5)
            pkmn.owner.name = "FishHead"
            pkmn.shiny = true
            pkmn.item = :SWEETAPPLE
          when "EASTER***"; pkmn = Pokemon.new(:EXEGGCUTE,5)
            pkmn.owner.name = "???"
            pkmn.shiny = true
          when "HALLOWEEN***"; pkmn = Pokemon.new(:PUMPKABOO,5)
            pkmn.owner.name = "???"
            pkmn.shiny = true
            pkmn.item = :RARECANDY
          when "CHRISTMAS***"; pkmn = Pokemon.new(:DELIBIRD,5)
            pkmn.owner.name = "???"
            pkmn.shiny = true
            pkmn.item = :ABILITYCAPSULE
          when "V0.9"; pkmn = Pokemon.new(:BIDOOF,5)
            pkmn.owner.name = "???"
            pkmn.shiny = true
            pkmn.ability = :MOODY
            pkmn.learn_move(:THIEF)
            pkmn.item = :ABILITYCAPSULE
          when "UNKNOWNGRASS"; pkmn = Pokemon.new(:MALIZAR,5)
            pkmn.owner.name = "???"
            pkmn.shiny = false
          when "UNKNOWNFIRE"; pkmn = Pokemon.new(:OTTORCH,5)
            pkmn.owner.name = "???"
            pkmn.shiny = false
          when "UNKNOWNWATER"; pkmn = Pokemon.new(:HYDRARK,5)
            pkmn.owner.name = "???"
            pkmn.shiny = false
          when "TITLENAME"; item = "Ability Patch"
        end

        if pkmn
          pkmn.owner.id = 00000
          pkmn.poke_ball = :CHERISHBALL
          pbAddPokemon(pkmn)
        end
        if item
          vRI(item, 1)
        end

        $usedCodes.push(code.upcase)
      end

  else
    pbMessage(_INTL("{1} is not a valid code.",code))
  end

end
