# frozen_string_literal: true

class Users::Component::ProfileDetails < Base::Component::Base
  def initialize(user:, **)
    @user = user
  end
end
