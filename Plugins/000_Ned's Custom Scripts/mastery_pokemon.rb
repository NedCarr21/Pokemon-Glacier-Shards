class Pokemon
  attr_accessor :mastery_progress, :special_ability_unlocked, :mastery_ability

  def setup_mastery_data
    @mastery_progress ||= []
    @mastery_tasks ||= []
    4.times do |i|
      task = MasteryData.select_variant_for(i, self)
      @mastery_tasks[i] = task
      @mastery_progress[i] ||= {
        status: i == 0 ? :active : :locked,
        progress: 0
      }
    end
    @mastery_ability = GameData::Ability.get(MasteryData.ability_for(self.species, self.form))
    @special_ability_unlocked ||= false
  end

  def mastery_tasks
    return @mastery_tasks
  end

  def mastery_progress
    return @mastery_progress
  end

  def mastery_ability
    return @mastery_ability
  end

  def special_ability_unlocked
    return @special_ability_unlocked
  end

  def task_name(index)
    task = self.mastery_tasks[index]
    case task[:task_type]
    when :UseMoveType
      name = "Use " + task[:args][0].to_s.capitalize + " Type Moves"
    when :TypeDamageDealt
      name = "Deal " + task[:args][0].to_s.capitalize + " Type Damage"
    when :BattleParticipation
      name = "Participate in Battles"
    end
    return name
  end

  def refresh_unstarted_masteries
    ret = false
    4.times do |i|
      next if self.mastery_progress[i] && self.mastery_progress[i][:progress] > 0
      task = MasteryData.select_variant_for(i, self)
      @mastery_tasks[i] = task
      @mastery_progress[i] = {
        status: i == 0 ? :active : :locked,
        progress: 0
      }
      ret = true
    end
    return ret
  end

  def can_unlock_mastery?(index)
    return false unless (index == 0 || self.mastery_progress[index - 1][:status] == :claimed)
    task = self.mastery_tasks[index]
    reqs = task[:requirement] || []
    return true if reqs.empty?

    i = 0
    while i < reqs.length
      case reqs[i]
      when "Level"
        return self.level >= reqs[i + 1].to_i
        i += 2
      when "Form"
        return self.form == reqs[i + 1].to_i
        i += 2
      when "Item"
        return self.item_id == reqs[i + 1].to_sym
        i += 2
      when "Location"
        return $game_map.name.upcase.tr(" ", "_").to_sym == reqs[i + 1].to_sym
        i += 2
      when "Flag"
        return $game_switches[reqs[i + 1].to_sym]
        i += 2
      when "Script"
        return Kernel.send(reqs[i + 1].to_sym, self)
        i += 2
      else
        i += 1
      end
    end
    return true
  end

  def current_mastery_index?
    ret = 0
    ret = 3 if @special_ability_unlocked
    4.times do |i|
      if self.mastery_progress[i][:status] != :locked
        ret = i
      end
    end
    return ret
  end

  def mastery_status(index)
    return self.mastery_progress[index][:status]
  end

  def complete_mastery?(index)
    return self.mastery_progress[index][:status] == :complete
  end

  def claim_mastery_reward(index)
    return unless complete_mastery?(index)
    rewards = self.mastery_tasks[index][:reward]
    rewards.each do |item_sym, qty|
      pbReceiveItem(item_sym, qty)
    end
    self.mastery_progress[index][:status] = :claimed
    unlock_next_mastery(index)
    return nil
  end

  def unlock_next_mastery(index)
    if index + 1 < 4 && can_unlock_mastery?(index + 1)
      self.mastery_progress[index + 1][:status] = :active
    elsif index + 1 == 4
      @special_ability_unlocked = true
      pbMessage(_INTL("{1} unlocked its Special Ability!", self.name))
    end
  end

  def increment_mastery_progress(task_type, *args)
    4.times do |i|
      task = self.mastery_tasks[i]
      next unless mastery_status(i) == :active
      next unless task && task[:task_type] == task_type

      match = case task_type
      when :KnockoutsWithType
        args[0] == task[:args][0].to_sym
      when :WinInWeather
        task[:args][0..-2].map(&:to_sym).include?(args[0])
      when :CriticalHits
        true
      when :UseMoveType
        args[0] == task[:args][0].to_sym
      when :UseMove
        args[0] == task[:args][0].to_sym
      when :SoloTypeWinInWeather
        args[0] == task[:args][0].to_sym && args[1] == task[:args][1].to_sym
      when :StatusInflictions
        args[0] == task[:args][0].to_sym
      when :BattleParticipation
        true
      when :TypeDamageDealt
        args[0] == task[:args][0].to_sym
      when :MoveDamageCategory
        args[0] == task[:args][0].to_sym
      when :ScriptCheck
        Kernel.send(task[:args][0].to_sym, self, *args)
      else
        false
      end

      if match
        self.mastery_progress[i][:progress] += 1
        target = task[:args].last.to_i
        if self.mastery_progress[i][:progress] >= target
          self.mastery_progress[i][:status] = :complete
          pbMessage(_INTL("{1} completed Mastery: {2}!", self.name, task[:name] || "Unknown"))
        end
      end
    end
    return nil
  end
end
