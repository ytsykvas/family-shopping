class User < ApplicationRecord
  # TODO: Refactor this model methods to use the Friendship model
  include Devise::JWT::RevocationStrategies::Denylist

  after_create :create_default_shopping_lists

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, :omniauthable,
         jwt_revocation_strategy: self,
         omniauth_providers: [ :google_oauth2 ]

  before_validation :generate_nickname_if_missing

  validates :name, presence: true
  validates :nickname, presence: true
  validates :nickname, uniqueness: { case_sensitive: false }, allow_blank: true

  has_many :sent_friendships,
           class_name: "Friendship",
           foreign_key: :requester_id,
           dependent: :destroy

  has_many :received_friendships,
           class_name: "Friendship",
           foreign_key: :accepter_id,
           dependent: :destroy

  has_many :owned_shopping_lists, class_name: "ShoppingList", foreign_key: :owner_id, dependent: :destroy
  has_many :shopping_list_users, dependent: :destroy
  has_many :shared_shopping_lists, through: :shopping_list_users, source: :shopping_list

  has_many :sent_shopping_list_invitations, class_name: "ShoppingListInvitation", foreign_key: :inviter_id, dependent: :destroy
  has_many :received_shopping_list_invitations, class_name: "ShoppingListInvitation", foreign_key: :invitee_id, dependent: :destroy

  has_many :wishlist_items, dependent: :destroy
  has_many :recipes, dependent: :destroy

  has_many :accepted_sent_friends,
           -> { where(friendships: { status: Friendship.statuses[:accepted] }) },
           through: :sent_friendships,
           source: :accepter

  has_many :accepted_received_friends,
           -> { where(friendships: { status: Friendship.statuses[:accepted] }) },
           through: :received_friendships,
           source: :requester

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:email))
      where(conditions.to_h).where([ "lower(email) = :value OR lower(nickname) = :value", { value: login.downcase } ]).first
    elsif conditions.has_key?(:email) || conditions.has_key?(:nickname)
      where(conditions.to_h).first
    end
  end

  def jwt_payload
    {
      "sub" => id.to_s,
      "email" => email,
      "jti" => SecureRandom.uuid,
      "exp" => 24.hours.from_now.to_i
    }
  end

  def friends
    User.where(id: accepted_sent_friends.select(:id))
        .or(User.where(id: accepted_received_friends.select(:id)))
  end

  # def send_friend_request!(other, message: nil)
  #   raise ArgumentError, "Cannot send friend request to yourself" if id == other.id

  #   Friendship.create!(requester: self, accepter: other, status: :pending, message: message)
  # end

  # def accept_friend_request!(other)
  #   friendship = Friendship.find_by!(requester: other, accepter: self, status: :pending)
  #   friendship.update!(status: :accepted)
  # end

  # def reject_friend_request!(other)
  #   friendship = Friendship.find_by!(requester: other, accepter: self, status: :pending)
  #   friendship.destroy!
  # end

  # def block_user!(other)
  #   friendship = Friendship.between_users(self, other).first
  #   if friendship
  #     friendship.update!(status: :blocked)
  #   else
  #     Friendship.create!(requester: self, accepter: other, status: :blocked)
  #   end
  # end

  def friends_with?(other)
    Friendship.accepted
              .where(
                "(requester_id = :me AND accepter_id = :other) OR (requester_id = :other AND accepter_id = :me)",
                me: id, other: other.id
              ).exists?
  end

  def pending_friend_request_to?(other)
    Friendship.pending.exists?(requester: self, accepter: other)
  end

  def pending_friend_request_from?(other)
    Friendship.pending.exists?(requester: other, accepter: self)
  end

  def pending_sent_requests
    User.joins(:received_friendships)
        .where(friendships: { requester_id: id, status: Friendship.statuses[:pending] })
  end

  def pending_received_requests
    User.joins(:sent_friendships)
        .where(friendships: { accepter_id: id, status: Friendship.statuses[:pending] })
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name

      # Generate unique nickname
      base_nickname = auth.info.email.split("@").first
      nickname = base_nickname
      counter = 1
      while User.exists?(nickname: nickname)
        nickname = "#{base_nickname}#{counter}"
        counter += 1
      end
      user.nickname = nickname
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.google_data"] && session["devise.google_data"]["info"]
        user.email = data["email"] if user.email.blank?
        user.name = data["name"] if user.name.blank?
        # Attempt to pre-fill nickname if not present
        if user.nickname.blank? && data["email"].present?
          base = data["email"].split("@").first
          user.nickname = base unless User.exists?(nickname: base)
        end
      end
    end
  end

  private

  def generate_nickname_if_missing
    return if nickname.present? || email.blank?

    base_nickname = email.split("@").first
    generated_nickname = base_nickname
    counter = 1
    while User.exists?(nickname: generated_nickname)
      generated_nickname = "#{base_nickname}#{counter}"
      counter += 1
    end
    self.nickname = generated_nickname
  end

  def create_default_shopping_lists
    owned_shopping_lists.create!(name: "Home")
    owned_shopping_lists.create!(name: "Presents")
  end
end
