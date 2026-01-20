class CreateWishlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :wishlist_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :url
      t.decimal :price, precision: 10, scale: 2
      t.string :currency, default: "USD"
      t.integer :status, default: 0
      t.references :booked_by_user, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
