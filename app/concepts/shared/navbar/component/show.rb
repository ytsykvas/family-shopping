# frozen_string_literal: true

class Shared::Navbar::Component::Show < ViewComponent::Base
  def initialize(current_user:, current_path: nil)
    @current_user = current_user
    @current_path = current_path
  end

  def active_link?(path)
    return false if @current_path.blank?

    @current_path.start_with?(path)
  end
end
