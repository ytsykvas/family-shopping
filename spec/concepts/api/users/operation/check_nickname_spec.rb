# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Users::Operation::CheckNickname do
  describe "#call" do
    let(:params) { { nickname: nickname } }
    let(:current_user) { nil }
    let(:result) { described_class.call(params: params, current_user: current_user) }

    context "when nickname is available" do
      let(:nickname) { Faker::Internet.unique.username(specifier: 5..20) }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns available true" do
        expect(result.model[:available]).to be true
      end

      it "returns availability message" do
        expected_message = I18n.t("api.users.nickname_available")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "when nickname is taken" do
      let!(:existing_user) { create(:user, nickname: "takenuser") }
      let(:nickname) { "takenuser" }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns available false" do
        expect(result.model[:available]).to be false
      end

      it "returns taken message" do
        expected_message = I18n.t("api.users.nickname_taken")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "when nickname is taken with different case" do
      let!(:existing_user) { create(:user, nickname: "ExistingUser") }
      let(:nickname) { "existinguser" }

      it "returns available false (case insensitive)" do
        expect(result.model[:available]).to be false
      end

      it "returns taken message" do
        expected_message = I18n.t("api.users.nickname_taken")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "when nickname is uppercase" do
      let!(:existing_user) { create(:user, nickname: "lowercase") }
      let(:nickname) { "LOWERCASE" }

      it "performs case-insensitive check" do
        expect(result.model[:available]).to be false
      end
    end
  end
end
