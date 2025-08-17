class Pokemon
  attr_accessor :achievements

  ACHIEVEMENTS = [
    :battles_won, :pkmn_defeated, :moves_used, :items_used,
    :times_fainted, :exp_gained, :steps_traveled,
  ]

  def load_achievements
    @achievements ||= {}
    ACHIEVEMENTS.each do |a|
      @achievements[a] ||= 0
    end
  end

  def get_achievement(sym)
    load_achievements if !@achievements
    return @achievements[sym]
  end

  def achievements
    load_achievements if !@achievements
    return @achievements
  end

  def modify_achievement(sym, value)
    load_achievements if !@achievements
    @achievements[sym] ||= 0
    @achievements[sym] += value
    # Kernel.echo("Pokemon: " + self.name + ", Achievement: "+ sym.to_s + ", Change: " + value.to_s + ", Value: " + @achievements[sym].to_s + "\n")
  end
end

EventHandlers.add(:on_player_step_taken, :increment_step_achievements,
  proc {
    $player.able_party.each do |pkmn|
      pkmn.modify_achievement(:steps_traveled, 1)
    end
  }
)
