module GameData
  class Recipe
    attr_reader :id
    attr_reader :item
    attr_reader :yield
    attr_reader :ingredients
    attr_reader :flags
    attr_reader :pbs_file_suffix
    
    DATA = {}
    DATA_FILENAME = "recipes.dat"
    PBS_BASE_FILENAME = "recipes"

    SCHEMA = {
      "SectionName" => [:id,          "m"],
      "Item"        => [:item,        "s"],
      "Yield"       => [:yield,       "v"],
      "Ingredients" => [:ingredients, "*sv"],
      "Flags"       => [:flags,       "*s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods
    
    def initialize(hash)
      @id          = hash[:id]
      @item        = hash[:item]
      @yield       = hash[:yield]       || 1
      @ingredients = hash[:ingredients]
      @flags       = hash[:flags]       || []
    end
    
    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end

module GameData
  class Item
    def self.flag_icon_filename(flag)
      return "Graphics/Items/back" if nil_or_empty?(flag)
      ret = sprintf("Graphics/Items/Category/%s", flag.downcase)
      return ret if pbResolveBitmap(ret)
      return "Graphics/Items/000"
    end
  end
end