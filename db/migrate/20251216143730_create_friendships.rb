# frozen_string_literal: true

class CreateFriendships < ActiveRecord::Migration[8.1]
  def change
    create_table :friendships do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :accepter,  null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0 # 0=pending, 1=accepted, 2=blocked

      t.timestamps
    end

    add_index :friendships, [ :requester_id, :accepter_id ], unique: true
    add_check_constraint :friendships, "requester_id <> accepter_id", name: "chk_friendships_not_self"
  end
end
