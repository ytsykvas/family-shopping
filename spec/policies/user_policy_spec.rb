# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "#show?" do
    context "when user is present" do
      it "allows access" do
        expect(subject.new(user, other_user).show?).to be true
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, other_user).show?).to be false
      end
    end
  end
end
