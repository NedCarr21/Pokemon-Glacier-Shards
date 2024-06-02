
#=======================================================================
# ADD ON: Remove all PokeEvent on load_save/transfer
# by TrankerGolD
#=======================================================================

#See  https://www.pokecommunity.com/showpost.php?p=10395097&postcount=382

#During the implementations of new features I've been wondering about how to handle PokeEvents as temporals, so pokemon are not there after saving and loading up your game.
#Since it is a hard task I came up with this Add-On that does something similar but in a forced manner.

#This Add-On is a simple idea that removes all PokeEvents when loading a save and when transferring.

#Concerning player transferring:
#	- Sometimes a transfer to the same map can happen, which won't clear and update the map
#	- If you want to use it on specific transfers you will have to delete the last part ("#Overide transfer_player"...) and call "pbRemovePokeEvents" right before transferring to another location of the same map.

#Also, with this Add-On you can call the script "pbRemovePokeEvents" inside any event whenever needed.

##===============================================================================
## new methods to remove pkmn spawned
##===============================================================================
#Remove all spawned events
def pbRemovePokeEvents
  if $MapFactory
    for map in $MapFactory.maps
      for event in map.events.values
        if event.is_a?(Game_PokeEvent)
          event.removeThisEventfromMap
        end
      end
    end
  else
    pbRemovePokeEventsInMap
  end
end

#Remove spawned events in current map
def pbRemovePokeEventsInMap
  $game_map.events.values.each { |event|
    if event.is_a?(Game_PokeEvent)
      event.removeThisEventfromMap
    end
  }
end

#Overide load_map
module Game
  class << self
    alias original_load_map load_map
  end
  def self.load_map
    original_load_map
    pbRemovePokeEvents
  end
end

#Overide transfer_player (optional)
class Scene_Map
  alias original_transfer_player transfer_player
  def transfer_player(cancelVehicles=true)
    pbRemovePokeEvents
    original_transfer_player(cancelVehicles)
  end
end
