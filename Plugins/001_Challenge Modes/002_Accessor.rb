module ChallengeModes

  module_function
  #-----------------------------------------------------------------------------
  # Select rules for challenge mode
  #-----------------------------------------------------------------------------
  def select_mode
    selected_rules = []
    loop do
      selected_rules = select_custom_rules
      if selected_rules.empty?
        next if Kernel.pbMessage(_INTL("Would you like to play the game without any challenge modifiers?"), [_INTL("Yes"), _INTL("No")]) != 0
      else
        next if Kernel.pbMessage(_INTL("Would you like to play the game with your selected modifiers?"), [_INTL("Yes"), _INTL("No")]) != 0
      end
      break
    end
    return selected_rules
  end
  #-----------------------------------------------------------------------------
  # Select custom ruleset for challenge
  #-----------------------------------------------------------------------------
  def select_custom_rules
    selected_rules = []
    last_custom_preset = []
    catch_clauses = [:SHINY_CLAUSE, :DUPS_CLAUSE, :GIFT_CLAUSE]
    presets = PRESETS.keys.clone
    presets.sort! { |a, b| PRESETS[a][:order] <=> PRESETS[b][:order] }
    vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    infowindow = Window_UnformattedTextPokemon.newWithSize("", 0, Graphics.height - 96, Graphics.width, 96, vp)
    infowindow.setSkin(MessageConfig.pbGetSystemFrame)
    cmdwindow = Window_CommandPokemon_Challenge.new([])
    cmdwindow.viewport = vp
    cmdwindow.y = 64
    text = _INTL("Challenge Options")
    titlewindow = Window_UnformattedTextPokemon.newWithSize(
      text, 0, 0, Graphics.width, 64, vp)
    need_refresh = true
    rules = RULES.keys.clone
    rules.sort! { |a, b| RULES[a][:order] <=> RULES[b][:order] }
    pbSetNarrowFont(infowindow.contents)
    infowindow.text = _INTL("Select from various challenge mode presets.")
    defaultskin = MessageConfig.pbGetSystemFrame.gsub("Graphics/Windowskins/", "")
    current_mode = 0
    loop do
      if need_refresh
        commands = []
        mode_name = _INTL("Custom")
        current_mode = 0
        PRESETS.each_value do |preset|
          next if preset[:rules] != selected_rules
          mode_name = preset[:name]
          current_mode = preset[:order]
          break
        end
        commands.push([_INTL("Challenge Preset"), mode_name])
        rules.each do |rule|
          rule_data = ChallengeModes::RULES[rule]
          toggle = selected_rules.include?(rule) ? 1 : 0
          commands.push([rule_data[:name], toggle, rule])
        end
        commands.push(_INTL("Confirm"))
        cmdwindow.commands = commands
        cmdwindow.width = Graphics.width
        cmdwindow.height = Graphics.height - 160
        need_refresh = false
      end
      Graphics.update
      Input.update
      old_index = cmdwindow.index
      cmdwindow.update
      infowindow.update
      pbUpdateSceneMap
      if old_index != cmdwindow.index
        text = ""
        if cmdwindow.index == 0
          text = _INTL("Select from various challenge mode presets.")
        elsif cmdwindow.index == cmdwindow.commands.length - 1
          text = _INTL("Confirm the following selection of modifiers.")
        else
          text = RULES[rules[cmdwindow.index - 1]][:desc]
        end
        pbSetNarrowFont(infowindow.contents)
        infowindow.text = _INTL(text)
        old_index = cmdwindow.index
      end
      if Input.trigger?(Input::LEFT) && cmdwindow.index == 0
        old_mode = current_mode
        current_mode -= 1
        current_mode = presets.length if current_mode < 0
        next if old_mode == current_mode
        pbPlayCursorSE
        last_custom_preset = selected_rules.clone if old_mode == 0
        selected_rules = (current_mode == 0) ? last_custom_preset : PRESETS[presets[current_mode - 1]][:rules].clone
        need_refresh = true
      elsif Input.trigger?(Input::RIGHT) && cmdwindow.index == 0
        old_mode = current_mode
        current_mode += 1
        current_mode = 0 if current_mode > presets.length
        next if old_mode == current_mode
        pbPlayCursorSE
        last_custom_preset = selected_rules.clone if old_mode == 0
        selected_rules = (current_mode == 0) ? last_custom_preset : PRESETS[presets[current_mode - 1]][:rules].clone
        need_refresh = true
      elsif Input.trigger?(Input::B)
        infowindow.visible = false
        break if selected_rules.empty?
        if Kernel.pbConfirmMessage(_INTL("\\w[{1}]Clear current selection of modifiers?", defaultskin))
          last_custom_preset = selected_rules.clone if current_mode == 0
          selected_rules.clear
        end
        infowindow.visible = true
        need_refresh = true
      elsif Input.trigger?(Input::C) && cmdwindow.index != 0
        command = cmdwindow.index
        break if command == ChallengeModes::RULES.values.length + 1
        rule = rules[command - 1]
        updated = false
        last_custom_preset = selected_rules.clone if current_mode == 0
        if selected_rules.include?(rule)
          selected_rules.delete(rule)
          catch_clauses.each { |r| selected_rules.delete(r) } if rule == :ONE_CAPTURE
          updated = true
        elsif !catch_clauses.include?(rule) || selected_rules.include?(:ONE_CAPTURE)
          selected_rules.push(rule)
          updated = true
        end
        if !updated
          pbPlayBuzzerSE
        else
          pbPlayCursorSE
          selected_rules.sort! { |a, b| RULES[a][:order] <=> RULES[b][:order] }
          need_refresh = true
        end
      end
    end
    cmdwindow.dispose
    infowindow.dispose
    titlewindow.dispose
    vp.dispose
    return selected_rules
  end

  def display_rules(rules)
    vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    infowindow = Window_AdvancedTextPokemon.newWithSize("", 0, 0, Graphics.width, Graphics.height, vp)
    infowindow.setSkin(MessageConfig.pbGetSystemFrame)
    infowindow.letterbyletter = true
    infowindow.lineHeight(28)
    rule_text  = ""
    rules.each_with_index do |rule, i|
      next if rule == :GAME_OVER_WHITEOUT
      rule_text += "- " + _INTL(ChallengeModes::RULES[rule][:desc])
      rule_text += "\n" if i != rules.length - (rules.include?(:GAME_OVER_WHITEOUT) ? 2 : 1)
    end
    pbSetSmallFont(infowindow.contents)
    infowindow.text = rule_text
    infowindow.resizeHeightToFit(rule_text)
    infowindow.height = Graphics.height if infowindow.height > Graphics.height
    infowindow.y = (Graphics.height - infowindow.height) / 2
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      infowindow.update
      pbUpdateSceneMap
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        if infowindow.busy?
          pbPlayDecisionSE if infowindow.pausing?
          infowindow.resume
        else
          break
        end
      end
    end
    rule_text  = ""
    if rules.include?(:GAME_OVER_WHITEOUT)
      rule_text += "- " + _INTL(ChallengeModes::RULES[:GAME_OVER_WHITEOUT][:desc])
    else
      rule_text += "- " + _INTL("If all your party Pokémon faint in battle, you will be allowed to continue the challenge with unfainted Pokémon from your PC.")
      rule_text += "\n- " + _INTL("If all the Pokémon in your Party and PC faint, you will lose the challenge.")
    end
    rule_text += "\n"
    rule_text += "- " + _INTL("You can forfeit the challenge at any time at this PC.") + "\n"
    rule_text += "- " + _INTL("The challenge begins after you have obtained your first Pokéball.") + "\n"
    rule_text += "- " + _INTL("The challenge ends at the end of the main story.") + "\n"
    rule_text += "- " + _INTL("You will receive a badge in the Hall of Fame upon successfully completing the challenge.")
    pbSetSmallFont(infowindow.contents)
    infowindow.text = rule_text
    infowindow.resizeHeightToFit(rule_text)
    infowindow.height = Graphics.height if infowindow.height > Graphics.height
    infowindow.y = (Graphics.height - infowindow.height) / 2
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      infowindow.update
      pbUpdateSceneMap
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        if infowindow.busy?
          pbPlayDecisionSE if infowindow.pausing?
          infowindow.resume
        else
          break
        end
      end
    end
    infowindow.dispose
    vp.dispose
  end
  #-----------------------------------------------------------------------------
end

class Window_CommandPokemon_Challenge < Window_CommandPokemon
  def initialize(commands, width = nil)
    @text_key = []
    @rule_sym = []
    commands.each_with_index do |command, i|
      next if !command.is_a?(Array)
      commands[i]  = command[0]
      @text_key[i] = command[1]
      @rule_sym[i] = command[2]
    end
    @l_bmp = RPG::Cache.load_bitmap("Graphics/UI/", "sel_arrow_left")
    @icons = RPG::Cache.load_bitmap("Graphics/UI/Trainer Card/", "icon_challenge_s")
    @max_option_width = nil
    super(commands, width)
  end

  def drawItem(index, count, rect)
    pbSetNarrowFont(self.contents)
    rect = drawCursor(index, rect)
    base   = self.baseColor
    shadow = self.shadowColor
    x_pos = rect.x
    y_pos = rect.y
    if @rule_sym[index]
      w = @icons.width
      x_pos += w
      rule_id = ChallengeModes::RULES[@rule_sym[index]][:order]
      self.contents.blt(rect.x, y_pos + (32 - w) / 2 + 1, @icons, Rect.new(0, w * rule_id, w, w))
    end
    pbDrawShadowText(self.contents, x_pos + 4, y_pos,
      rect.width, rect.height, @commands[index], base, shadow)
    return if !@text_key[index]
    text = _INTL("OFF")
    base   = Color.new(232, 32, 16)
    shadow = Color.new(248, 168, 184)
    if @text_key[index].is_a?(String)
      text = @text_key[index]
      base = Color.new(96, 176,  72)
      shadow = Color.new(174, 208, 144)
    elsif @text_key[index] == 1
      text = _INTL("ON")
      base   = Color.new(0, 112, 248)
      shadow = Color.new(120, 184, 232)
    end
    text = "[#{text}]"
    option_width = rect.width / 2
    x_pos += rect.width - option_width
    x_pos -= @icons.width if @rule_sym[index]
    pbSetSystemFont(self.contents)
    if @text_key[index].is_a?(String)
      option_width -= 32
      x_pos += 16
      y_pos += 4
      pbCopyBitmap(self.contents, @l_bmp, x_pos - 16, y_pos)
      pbCopyBitmap(self.contents, @selarrow.bitmap, x_pos + option_width + 4, y_pos)
    end
    pbDrawShadowText(self.contents, x_pos, rect.y, option_width, rect.height, text, base, shadow, 1)
  end

  def commands=(commands)
    @text_key = []
    @rule_sym = []
    commands.each_with_index do |command, i|
      next if !command.is_a?(Array)
      commands[i]  = command[0]
      @text_key[i] = command[1]
      @rule_sym[i] = command[2]
    end
    @commands = commands
    @max_option_width = nil
  end

  def dispose
    super
    @l_bmp.dispose
    @icons.dispose
  end
end
