
module MasteryData

  @lines = {}
  @level_reqs = {}

  def self.load
    return if !File.exist?("PBS/mastery_data.txt")
    current = nil
    index = nil
    File.foreach("PBS/mastery_data.txt") do |line|
      line.strip!
      next if line.empty? || line.start_with?("#")

      if line.start_with?("[") && line.end_with?("]")
        current = line[1...-1].upcase.to_sym
        @lines[current] ||= { tasks: Array.new(4) { [] }, ability: nil }
        index = nil
      elsif line =~ /^Mastery(\d)$/i
        index = $1.to_i - 1
        @lines[current][:tasks][index] ||= []
        @lines[current][:tasks][index] << {}
      elsif line.include?("=") && current && !index.nil?
        key, value = line.split("=", 2).map(&:strip)
        task = @lines[current][:tasks][index].last

        case key
        when "Task"
          parts = value.split(",").map(&:strip)
          task[:task_type] = parts[0].to_sym
          task[:args] = parts[1..]
        when "Condition"
          task[:conditions] ||= []
          cond_type, cond_value = value.split(",", 2).map(&:strip)
          task[:conditions] << { type: cond_type.to_sym, value: cond_value.to_sym }
        when "Requirement"
          task[:requirement] ||= []
          task[:requirement] += value.split(",").map(&:strip)
        when "Reward"
          task[:reward] ||= []
          item, qty = value.split(",", 2).map(&:strip)
          task[:reward] << [item.to_sym, qty.to_i]
        when "SpecialAbility"
          @lines[current][:ability] = value.to_sym
        when "UseLine"
          source = value.upcase.to_sym
          task = @lines[current] = @lines[source]
        end
      end
    end
  end

  def self.tasks_for(species, form = 0)
    load if @lines.empty?
    form_key = "#{species.upcase}_#{form}".to_sym
    base_key = species.upcase.to_sym
    default_key = :_DEFAULT
    return @lines[form_key]&.[](:tasks) || @lines[base_key]&.[](:tasks) || @lines[default_key]&.[](:tasks) || []
  end

  def self.ability_for(species, form = 0)
    load if @lines.empty?
    form_key = "#{species.upcase}_#{form}".to_sym
    base_key = species.upcase.to_sym
    default_key = :_DEFAULT
    return @lines[form_key]&.[](:ability) || @lines[base_key]&.[](:ability) || @lines[default_key]&.[](:ability)
  end

  def self.select_variant_for(index, pokemon)
    tasks = tasks_for(pokemon.species, pokemon.form)
    return nil unless tasks[index]
    result = tasks[index].find do |task|
      next true unless task[:conditions] && !task[:conditions].empty?
      task[:conditions].all? do |cond|
        case cond[:type]
          when :Nature
            pokemon.nature == cond[:value]
          when :Pokeball
            pokemon.poke_ball == cond[:value]
          when :IV
            pokemon.iv_stats.max_by.with_index { |v, i| [v, i] }[1] == GameData::Stat.get(cond[:value]).id_number
          when :Script
            Kernel.send(cond[:value], pokemon)
          else
            false
        end
      end
    end
    return result
  end

  def self.load_level_req
    GameData::Species.each do |data|
      spec = data.species
      next if !pbAllRegionalSpecies(0).include?(spec)
      level_req = 15
      case spec
      when :SWINUB
        level_req = 25
      when :PILOSWINE
        level_req = 40
      when :MAGIKARP
        level_req = 5
      end
      @level_reqs[spec] = level_req
    end
  end

  def self.get_level_req(species)
    load_level_req if (@level_reqs.empty? || !@level_reqs[species])
    return @level_reqs[species]
  end
end
