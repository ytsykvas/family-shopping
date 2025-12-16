# frozen_string_literal: true

class Friends::Component::Index < Base::Component::Base
  def initialize(friends:)
    @friends = friends
  end
end
