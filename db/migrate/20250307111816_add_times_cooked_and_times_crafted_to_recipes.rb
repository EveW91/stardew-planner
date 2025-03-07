class AddTimesCookedAndTimesCraftedToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :times_cooked, :integer
    add_column :recipes, :times_crafted, :integer
  end
end
