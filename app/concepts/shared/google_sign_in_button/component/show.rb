# frozen_string_literal: true

class Shared::GoogleSignInButton::Component::Show < Base::Component::Base
  def initialize(text_key: "sessions.form.google_sign_in")
    @text_key = text_key
  end

  private

  attr_reader :text_key
end
