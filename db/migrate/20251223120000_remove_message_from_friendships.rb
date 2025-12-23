# frozen_string_literal: true

class RemoveMessageFromFriendships < ActiveRecord::Migration[8.1]
  def change
    remove_column :friendships, :message, :text
  end
end
