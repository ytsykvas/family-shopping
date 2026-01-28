# frozen_string_literal: true

class Base::Component::Header < Base::Component::Base
  def initialize(title:)
    @title = title
  end
end
