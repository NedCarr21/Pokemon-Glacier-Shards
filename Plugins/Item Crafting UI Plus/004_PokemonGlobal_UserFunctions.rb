class PokemonGlobalMetadata
  def recipes
    @recipes = [] unless @recipes
    return @recipes
  end
end

def pbUnlockRecipe(recipe_id)
  $PokemonGlobal.recipes.push(recipe_id)
  $PokemonGlobal.recipes.uniq!
end

def pbLockRecipe(recipe_id)
  return unless $PokemonGlobal.recipes.include?(recipe_id)
  $PokemonGlobal.recipes.delete(recipe_id)
end

def pbGetRecipes(flag=nil)
  ret = []
  $PokemonGlobal.recipes.each do |recipe|
    next if flag && !GameData::Recipe.get(recipe).has_flag?(flag)
    ret.push(recipe)
  end
  return ret
end