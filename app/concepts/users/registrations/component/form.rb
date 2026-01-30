# frozen_string_literal: true

class Users::Registrations::Component::Form < Base::Component::Base
  def initialize(resource:, resource_name:)
    @resource = resource
    @resource_name = resource_name
  end

  private

  attr_reader :resource, :resource_name
end
