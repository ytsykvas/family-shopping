# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    describe "sent_friendships" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      it "has many sent friendships" do
        friendship = create(:friendship, requester: user, accepter: other_user)
        expect(user.sent_friendships).to include(friendship)
      end

      it "destroys sent friendships when user is destroyed" do
        friendship = create(:friendship, requester: user, accepter: other_user)
        user.destroy
        expect(Friendship.find_by(id: friendship.id)).to be_nil
      end
    end

    describe "received_friendships" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      it "has many received friendships" do
        friendship = create(:friendship, requester: other_user, accepter: user)
        expect(user.received_friendships).to include(friendship)
      end

      it "destroys received friendships when user is destroyed" do
        friendship = create(:friendship, requester: other_user, accepter: user)
        user.destroy
        expect(Friendship.find_by(id: friendship.id)).to be_nil
      end
    end

    describe "accepted_sent_friends" do
      let(:user) { create(:user) }
      let(:accepted_friend) { create(:user) }
      let(:pending_friend) { create(:user) }

      it "returns only accepted friends from sent requests" do
        create(:friendship, :accepted, requester: user, accepter: accepted_friend)
        create(:friendship, :pending, requester: user, accepter: pending_friend)

        expect(user.accepted_sent_friends).to include(accepted_friend)
        expect(user.accepted_sent_friends).not_to include(pending_friend)
      end
    end

    describe "accepted_received_friends" do
      let(:user) { create(:user) }
      let(:accepted_friend) { create(:user) }
      let(:pending_friend) { create(:user) }

      it "returns only accepted friends from received requests" do
        create(:friendship, :accepted, requester: accepted_friend, accepter: user)
        create(:friendship, :pending, requester: pending_friend, accepter: user)

        expect(user.accepted_received_friends).to include(accepted_friend)
        expect(user.accepted_received_friends).not_to include(pending_friend)
      end
    end
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

  describe "#friends" do
    let(:user) { create(:user) }
    let(:friend1) { create(:user) }
    let(:friend2) { create(:user) }
    let(:friend3) { create(:user) }
    let(:non_friend) { create(:user) }

    context "when user has no friends" do
      it "returns empty collection" do
        expect(user.friends).to be_empty
      end
    end

    context "when user has friends from sent requests" do
      before do
        create(:friendship, :accepted, requester: user, accepter: friend1)
        create(:friendship, :accepted, requester: user, accepter: friend2)
      end

      it "returns accepted friends from sent requests" do
        expect(user.friends).to include(friend1, friend2)
      end

      it "does not return pending friends" do
        pending_friend = create(:user)
        create(:friendship, :pending, requester: user, accepter: pending_friend)
        expect(user.friends).not_to include(pending_friend)
      end

      it "does not return non-friends" do
        expect(user.friends).not_to include(non_friend)
      end
    end

    context "when user has friends from received requests" do
      before do
        create(:friendship, :accepted, requester: friend1, accepter: user)
        create(:friendship, :accepted, requester: friend2, accepter: user)
      end

      it "returns accepted friends from received requests" do
        expect(user.friends).to include(friend1, friend2)
      end

      it "does not return pending friends" do
        pending_friend = create(:user)
        create(:friendship, :pending, requester: pending_friend, accepter: user)
        expect(user.friends).not_to include(pending_friend)
      end
    end

    context "when user has friends from both sent and received requests" do
      before do
        create(:friendship, :accepted, requester: user, accepter: friend1)
        create(:friendship, :accepted, requester: friend2, accepter: user)
        create(:friendship, :accepted, requester: user, accepter: friend3)
      end

      it "returns all accepted friends regardless of direction" do
        expect(user.friends).to contain_exactly(friend1, friend2, friend3)
      end

      it "does not return duplicates" do
        expect(user.friends.to_a.size).to eq(3)
      end
    end

    context "with blocked friendships" do
      before do
        create(:friendship, :accepted, requester: user, accepter: friend1)
        create(:friendship, :blocked, requester: user, accepter: friend2)
      end

      it "returns only accepted friends, not blocked" do
        expect(user.friends).to include(friend1)
        expect(user.friends).not_to include(friend2)
      end
    end
  end

  describe "default shopping lists" do
    let(:user) { create(:user) }

    it "creates 'Home' and 'Presents' shopping lists after user creation" do
      expect(user.owned_shopping_lists.pluck(:name)).to contain_exactly("Home", "Presents")
    end
  end
end
