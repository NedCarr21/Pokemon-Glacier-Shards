class BgStyles
  
  def setStyle(value)
    value ||= $PokemonSystem.bg_style
    return "Backgrounds/" + Settings::MENU_BGSTYLES[value]
  end

  def getStyle(value)
    return Settings::MENU_BGSTYLES[value].to_s
  end

end
