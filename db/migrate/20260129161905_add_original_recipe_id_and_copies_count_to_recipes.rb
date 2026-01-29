class AddOriginalRecipeIdAndCopiesCountToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :original_recipe_id, :bigint
    add_column :recipes, :copies_count, :integer, default: 0

    add_index :recipes, :original_recipe_id
    add_foreign_key :recipes, :recipes, column: :original_recipe_id
  end
end
