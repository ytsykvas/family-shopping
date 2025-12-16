# frozen_string_literal: true

class AddMessageToFriendships < ActiveRecord::Migration[8.1]
  def change
    add_column :friendships, :message, :text
  end
end
