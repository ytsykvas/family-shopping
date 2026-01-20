require 'rails_helper'

RSpec.describe WishlistItem, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:booked_by_user).class_name('User').optional }
    it { should have_one_attached(:image) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_inclusion_of(:currency).in_array(WishlistItem::CURRENCIES) }
    it { should define_enum_for(:status).with_values(pending: 0, booked: 1) }
  end
end
