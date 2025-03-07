class StardewSaveParser
  attr_reader :xml, :user, :player

  def initialize(file_path, user)
    # Ensure that the user is not nil before proceeding
    raise ArgumentError, "User cannot be nil" if user.nil?

    @file_path = file_path
    @xml = File.open(file_path) { |f| Nokogiri::XML(f) }
    @user = user  # Ensure this is a valid User object
  end

  def parse_and_store
    ActiveRecord::Base.transaction do
      parse_player
      parse_recipes
      parse_inventory
    end
  end

  private

  def parse_player
    # Ensure the user is set correctly
    raise "User not found" if @user.nil?

    name = xml.at_xpath("//player/name").text
    farm_name = xml.at_xpath("//player/farmName").text

    # Creating a player for the current user
    @player = @user.players.create!(name: name, save_file_path: @file_path)
    puts "✅ Player: #{name} (#{farm_name}) imported!"
  end

  def parse_recipes
    # Cooking Recipes
    xml.xpath("//cookingRecipes/item").each do |recipe|
      name = recipe.at_xpath("key/string").text
      times_cooked = recipe.at_xpath("value/int").text.to_i
      ingredients = parse_ingredients(recipe)

      Recipe.find_or_create_by!(name: name, category: "cooking") do |r|
        r.times_cooked = times_cooked
        r.ingredients = ingredients.join(", ")
      end
    end

    # Crafting Recipes
    xml.xpath("//craftingRecipes/item").each do |recipe|
      name = recipe.at_xpath("key/string").text
      times_crafted = recipe.at_xpath("value/int").text.to_i
      Recipe.find_or_create_by!(name: name, category: "crafting") do |r|
        r.times_crafted = times_crafted
        r.ingredients = ingredients.join(",")
      end
    end

    puts "✅ Recipes imported!"
  end

  def parse_ingredients(recipe)
    # Assuming the ingredients are nested within the recipe XML under some tag like "ingredients"
    ingredients = []

    # You can adjust this part depending on the exact XML structure
    recipe.xpath("ingredients/item").each do |ingredient_node|
      ingredient_name = ingredient_node.at_xpath("name").text
      ingredients << ingredient_name
    end

    ingredients
  end

  def parse_inventory
    xml.xpath("//player/items/item").each do |item|
      name = item.at_xpath("name").text
      quantity = item.at_xpath("Stack").text.to_i

      ingredient = Ingredient.find_or_create_by!(name: name)
      InventoryItem.create!(player: @player, ingredient: ingredient, quantity: quantity)
    end

    puts "✅ Inventory imported!"
  end
end
