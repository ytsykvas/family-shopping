# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    # Add associations tests here when you add them
  end

  describe "validations" do
    describe "name" do
      it { is_expected.to validate_presence_of(:name) }
    end

    describe "nickname" do
      it { is_expected.to validate_presence_of(:nickname) }
      it { is_expected.to validate_uniqueness_of(:nickname).case_insensitive }
    end

    describe "email" do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end

    describe "password" do
      it { is_expected.to validate_presence_of(:password).on(:create) }
      it { is_expected.to validate_length_of(:password).is_at_least(6) }
    end
  end

  describe ".find_for_database_authentication" do
    let!(:user) { create(:user, email: "test@example.com", nickname: "testuser") }

    context "when searching by email" do
      it "finds user by exact email" do
        result = described_class.find_for_database_authentication(email: "test@example.com")
        expect(result).to eq(user)
      end

      it "finds user by email case insensitive" do
        result = described_class.find_for_database_authentication(email: "TEST@EXAMPLE.COM")
        expect(result).to eq(user)
      end

      it "returns nil when email does not exist" do
        result = described_class.find_for_database_authentication(email: "nonexistent@example.com")
        expect(result).to be_nil
      end
    end

    context "when searching by nickname" do
      it "finds user by exact nickname" do
        result = described_class.find_for_database_authentication(email: "testuser")
        expect(result).to eq(user)
      end

      it "finds user by nickname case insensitive" do
        result = described_class.find_for_database_authentication(email: "TESTUSER")
        expect(result).to eq(user)
      end

      it "returns nil when nickname does not exist" do
        result = described_class.find_for_database_authentication(email: "nonexistent")
        expect(result).to be_nil
      end
    end

    context "when searching with additional conditions" do
      let!(:another_user) { create(:user, email: "another@example.com", nickname: "anotheruser") }

      it "finds user matching both email and additional conditions" do
        result = described_class.find_for_database_authentication(
          email: "test@example.com",
          id: user.id
        )
        expect(result).to eq(user)
      end

      it "returns nil when additional conditions do not match" do
        result = described_class.find_for_database_authentication(
          email: "test@example.com",
          id: another_user.id
        )
        expect(result).to be_nil
      end
    end

    context "when email parameter is not provided" do
      it "returns nil" do
        result = described_class.find_for_database_authentication({})
        expect(result).to be_nil
      end
    end
  end

  describe "#jwt_payload" do
    let(:user) { create(:user) }
    let(:payload) { user.jwt_payload }

    it "includes required keys" do
      expect(payload).to have_key("sub")
      expect(payload).to have_key("email")
      expect(payload).to have_key("jti")
      expect(payload).to have_key("exp")
    end

    it "sets sub to user id as string" do
      expect(payload["sub"]).to eq(user.id.to_s)
    end

    it "sets email to user email" do
      expect(payload["email"]).to eq(user.email)
    end

    it "generates a unique jti for each call" do
      first_jti = user.jwt_payload["jti"]
      second_jti = user.jwt_payload["jti"]
      expect(first_jti).not_to eq(second_jti)
    end

    it "sets exp to 24 hours from now" do
      expected_exp = 24.hours.from_now.to_i
      # Allow 5 seconds difference for execution time
      expect(payload["exp"]).to be_within(5).of(expected_exp)
    end

    it "exp is in the future" do
      expect(payload["exp"]).to be > Time.now.to_i
    end
  end

  describe "nickname uniqueness" do
    let!(:existing_user) { create(:user, nickname: "existinguser") }
    let(:taken_message) { I18n.t("activerecord.errors.models.user.attributes.nickname.taken") }

    context "with same case" do
      it "does not allow duplicate nickname" do
        new_user = build(:user, nickname: "existinguser")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:nickname]).to include(taken_message)
      end
    end

    context "with different case" do
      it "does not allow duplicate nickname with different case" do
        new_user = build(:user, nickname: "EXISTINGUSER")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:nickname]).to include(taken_message)
      end

      it "does not allow duplicate nickname with mixed case" do
        new_user = build(:user, nickname: "ExistingUser")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:nickname]).to include(taken_message)
      end
    end

    context "with different nickname" do
      it "allows different nickname" do
        new_user = build(:user, nickname: "differentuser")
        expect(new_user).to be_valid
      end
    end
  end

  describe "email uniqueness" do
    let!(:existing_user) { create(:user, email: "test@example.com") }
    let(:taken_message) { I18n.t("activerecord.errors.models.user.attributes.email.taken") }

    context "with same case" do
      it "does not allow duplicate email" do
        new_user = build(:user, email: "test@example.com")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:email]).to include(taken_message)
      end
    end

    context "with different case" do
      it "does not allow duplicate email with different case" do
        new_user = build(:user, email: "TEST@EXAMPLE.COM")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:email]).to include(taken_message)
      end
    end
  end

  describe "factory" do
    it "creates a valid user" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "creates a user with all required attributes" do
      user = create(:user)
      expect(user.name).to be_present
      expect(user.nickname).to be_present
      expect(user.email).to be_present
      expect(user.password).to be_present
    end

    context "with traits" do
      it "creates user with long password" do
        user = build(:user, :with_long_password)
        expect(user.password.length).to be >= 12
        expect(user.password.length).to be <= 30
        expect(user).to be_valid
      end

      it "creates user with short name" do
        user = build(:user, :with_short_name)
        expect(user.name).to be_present
        expect(user.name.split.length).to eq(1)
        expect(user).to be_valid
      end

      it "creates user with long name" do
        user = build(:user, :with_long_name)
        expect(user.name).to be_present
        expect(user.name.split.length).to be >= 3
        expect(user).to be_valid
      end
    end
  end

  describe "Devise functionality" do
    let(:user) { create(:user) }

    it "is database authenticatable" do
      expect(user).to respond_to(:valid_password?)
    end

    it "validates password correctly" do
      expect(user.valid_password?(user.password)).to be true
      expect(user.valid_password?("wrong_password")).to be false
    end

    it "is registerable" do
      expect(described_class.devise_modules).to include(:registerable)
    end

    it "is recoverable" do
      expect(described_class.devise_modules).to include(:recoverable)
    end

    it "is rememberable" do
      expect(described_class.devise_modules).to include(:rememberable)
    end

    it "is jwt_authenticatable" do
      expect(described_class.devise_modules).to include(:jwt_authenticatable)
    end
  end
end
