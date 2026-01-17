class CreateShoppingListInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_invitations do |t|
      t.references :shopping_list, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.references :invitee, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :shopping_list_invitations, [ :shopping_list_id, :invitee_id ], unique: true, name: "idx_shopping_list_invitations_unique"
  end
end
