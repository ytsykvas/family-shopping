# frozen_string_literal: true

class Users::Sessions::Component::New < Base::Component::Base
  def initialize(resource: nil, resource_name: nil, devise_mapping: nil)
    @resource = resource || User.new
    @resource_name = resource_name || :user
    @devise_mapping = devise_mapping || Devise.mappings[:user]
  end

  private

  attr_reader :resource, :resource_name, :devise_mapping
end
