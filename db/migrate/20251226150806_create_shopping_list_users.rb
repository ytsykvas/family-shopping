# frozen_string_literal: true

class CreateShoppingListUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_users do |t|
      t.references :shopping_list, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.index [ :shopping_list_id, :user_id ], unique: true

      t.timestamps
    end
  end
end
