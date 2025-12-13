# frozen_string_literal: true

class Shared::Navbar::Component::Show < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user
  end
end
