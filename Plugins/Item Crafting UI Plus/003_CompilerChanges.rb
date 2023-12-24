module GameData
  class << self
    alias _itemcrafter_load_all load_all
    def load_all
      _itemcrafter_load_all
      Recipe.load
    end
  end
end

module Compiler
  module_function
  #=============================================================================
  # Compile Recipes data
  #=============================================================================
    def compile_recipes(*paths)
    compile_PBS_file_generic(GameData::Recipe, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_recipes : validate_compiled_recipe(hash)
    end
  end

  def validate_compiled_recipe(hash)
    if hash[:ingredients].nil?
      raise _INTL("The entry 'Ingredients' is required in recipes.txt section {1}.\n{2}", data_hash[:id],FileLineData.linereport)
    end
    hash[:ingredients].map! do |x|
      next [x[0].to_sym,x[1]] if GameData::Item.exists?(x[0].to_sym)
      next x
    end
  end

  # no specific validation required
  def validate_all_compiled_recipes
  end
  
  class << self
    alias _itemcrafter_compile_pbs_files compile_pbs_files
    def compile_pbs_files
      _itemcrafter_compile_pbs_files
      text_files = get_all_pbs_files_to_compile
      compile_recipes(*text_files[:Recipe][1]) # Depends on Item
    end
  end
end