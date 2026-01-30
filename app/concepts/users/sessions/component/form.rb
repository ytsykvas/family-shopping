# frozen_string_literal: true

class Users::Sessions::Component::Form < Base::Component::Base
  def initialize(resource:, resource_name:, devise_mapping:)
    @resource = resource
    @resource_name = resource_name
    @devise_mapping = devise_mapping
  end

  private

  attr_reader :resource, :resource_name, :devise_mapping
end
