require 'rails_helper'

describe GlobalRecipePolicy do
  subject { described_class.new(user, :global_recipe) }

  let(:user) { create(:user) }

  it "permits index" do
    expect(subject.index?).to be true
  end

  it "permits show" do
    expect(subject.show?).to be true
  end

  it "permits add" do
    expect(subject.add?).to be true
  end
end
