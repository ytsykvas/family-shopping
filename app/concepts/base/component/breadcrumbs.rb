# frozen_string_literal: true

class Base::Component::Breadcrumbs < Base::Component::Base
  def initialize(items:, back_path: nil)
    @items = items
    @back_path = back_path
  end
end
