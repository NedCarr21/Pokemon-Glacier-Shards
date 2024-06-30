class Battle::Battler

  #New method to change the original item for a pokemon. Called only by the Clear Disk.
  def pbRemoveAndReplaceItem(new_item_id)
    setInitialItem(new_item_id) if self.item == self.initialItem
    self.item = new_item_id
  end

  alias_method :original_pbEffectsAfterMove, :pbEffectsAfterMove
  def pbEffectsAfterMove(user, targets, move, numHits)
    original_pbEffectsAfterMove(user, targets, move, numHits)
    
     # Print a message indicating the def was properly called
      puts "Entered pbEffectsAfterMove method for user: #{user.name} using move: #{move.name}"
    
    # Define what clear disk does
    if user.hasActiveItem?(:CLEARDISK) && rand(10) == 0
      puts "User has Clear Disk item."
      last_move_id = move.id
      puts "Last move ID: #{last_move_id}"
      GameData::Item.each do |item|
        next unless item.is_TR?
        next unless item.move == last_move_id
        new_item_id = item.id
		new_item_name = item.name
        self.pbRemoveAndReplaceItem(new_item_id)
        puts "User's item changed to: #{item.id}"
        @battle.pbCommonAnimation("UseItem", user)
        @battle.pbDisplay(_INTL("The Clear Disk recorded the move {1}! It became {2}!", move.name, new_item_name))
        break
      end
    end
  end
end