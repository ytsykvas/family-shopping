# frozen_string_literal: true

class CreateShoppingListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_items do |t|
      t.references :shopping_list, null: false, foreign_key: true
      t.string :name
      t.string :status, default: 'pending', null: false
      t.references :added_by, null: false, foreign_key: { to_table: :users }, index: true
      t.references :edited_by, null: true, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end
  end
end
