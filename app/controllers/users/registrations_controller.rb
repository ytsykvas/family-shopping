# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json, :html

    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def new
      endpoint Users::Registrations::Component::New, resource: resource, resource_name: resource_name, devise_mapping: devise_mapping
    end

    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        endpoint Users::Registrations::Component::New, resource: resource, resource_name: resource_name, devise_mapping: devise_mapping
      end
    end

    private

    def respond_with(resource, _opts = {})
      if request.format.json?
        if resource.persisted?
          render json: {
            status: { code: 200, message: "Signed up successfully." },
            data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :ok
        else
          render json: {
            status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" },
            data: resource.errors
          }, status: :unprocessable_entity
        end
      else
        if resource.persisted?
          super
        else
          endpoint Users::Registrations::Component::New, resource: resource, resource_name: resource_name, devise_mapping: devise_mapping
        end
      end
    end
  end
end
