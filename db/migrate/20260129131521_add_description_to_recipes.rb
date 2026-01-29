class AddDescriptionToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :description, :text
  end
end
