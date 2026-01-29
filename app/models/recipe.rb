class Recipe < ApplicationRecord
  belongs_to :user
  belongs_to :original_recipe, class_name: "Recipe", optional: true, counter_cache: :copies_count
  has_many :copies, class_name: "Recipe", foreign_key: :original_recipe_id, dependent: :nullify
  has_many :ingredients, dependent: :destroy

  accepts_nested_attributes_for :ingredients, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
end
