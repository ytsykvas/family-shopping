# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Users::Operation::CheckEmail do
  describe "#call" do
    let(:params) { { email: email } }
    let(:current_user) { nil }
    let(:result) { described_class.call(params: params, current_user: current_user) }

    context "when email is available and valid" do
      let(:email) { Faker::Internet.unique.email }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns available true" do
        expect(result.model[:available]).to be true
      end

      it "returns availability message" do
        expected_message = I18n.t("api.users.email_available")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "when email is taken" do
      let!(:existing_user) { create(:user, email: "taken@example.com") }
      let(:email) { "taken@example.com" }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns available false" do
        expect(result.model[:available]).to be false
      end

      it "returns taken message" do
        expected_message = I18n.t("api.users.email_taken")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "when email is taken with different case" do
      let!(:existing_user) { create(:user, email: "Test@Example.com") }
      let(:email) { "test@example.com" }

      it "returns available false (case insensitive)" do
        expect(result.model[:available]).to be false
      end

      it "returns taken message" do
        expected_message = I18n.t("api.users.email_taken")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "when email format is invalid" do
      let(:email) { "invalid-email-format" }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns available false" do
        expect(result.model[:available]).to be false
      end

      it "returns invalid format message" do
        expected_message = I18n.t("api.users.email_invalid")
        expect(result.model[:message]).to eq(expected_message)
      end
    end

    context "with various invalid email formats" do
      [
        "plaintext",
        "@nodomain.com",
        "missing@domain",
        "spaces in@email.com",
        "double@@domain.com"
      ].each do |invalid_email|
        context "when email is '#{invalid_email}'" do
          let(:email) { invalid_email }

          it "returns available false" do
            expect(result.model[:available]).to be false
          end

          it "returns invalid format message" do
            expected_message = I18n.t("api.users.email_invalid")
            expect(result.model[:message]).to eq(expected_message)
          end
        end
      end
    end

    context "when uppercase email is taken" do
      let!(:existing_user) { create(:user, email: "lowercase@example.com") }
      let(:email) { "LOWERCASE@EXAMPLE.COM" }

      it "performs case-insensitive check" do
        expect(result.model[:available]).to be false
      end
    end
  end
end
