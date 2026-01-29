# frozen_string_literal: true

class GlobalRecipe::Component::Filter < Base::Component::Base
  def initialize(params:)
    @params = params
  end

  private

  def filters_visible?
    @params.except(:action, :controller).present?
  end
end
