# frozen_string_literal: true

module OperationsMethods
  include ActionView::Helpers::JavaScriptHelper
  extend ActiveSupport::Concern

  protected

  def endpoint(operation_or_component, component = nil)
    # Check if first argument is a component (has no 'call' method)
    if component.nil? && !operation_or_component.respond_to?(:call)
      # Direct component rendering without operation
      render_component_only(operation_or_component)
    else
      # Operation + Component flow
      operation = operation_or_component
      result = operation.call(params:, current_user:)

      check_authorization_is_called result

      respond_to do |format|
        format.html do
          if action_name == "create" || action_name == "update" || action_name.include?("destroy")
            path = result.redirect_path || public_send("#{controller_name}_path")
            redirect_to path, notice: result.message, alert: result.error_message
          elsif action_name == "index"
            params = if result.model.is_a?(OpenStruct)
                       result.model.to_h
            else
                       key = operation.to_s.split("::").first.underscore.pluralize
                       { "#{key}": result.model }
            end

            render component.new(**params)
          elsif action_name == "edit" || action_name == "new"
            params = if result.model.is_a?(OpenStruct)
                       result.model.to_h
            else
                       key = operation.to_s.split("::").first.underscore
                       { "#{key}": result.model }
            end

            render component.new(**params)
          end
        end

      # We use it for Rendering new/edit modals
      format.js do
        params = if result.model.is_a?(OpenStruct)
                   result.model.to_h
        else
                   key = operation.to_s.split("::").first.underscore
                   { "#{key}": result.model }
        end

        if result.success? && (action_name == "create" || action_name == "update" || action_name.include?("destroy"))
          flash[:notice] = result.message
          path = result.redirect_path || public_send("#{controller_name}_path")
          render js: "window.location.href='#{path}'"
        else
          modal = render_to_string(component.new(**params), layout: false)
          render js: <<~JS
            var activeModal = document.querySelector('.modal.show');
            if (activeModal) {
                window.bootstrap.Modal.getOrCreateInstance(activeModal).hide();
            }
            document.getElementById('modals').innerHTML = "";
            var renderedHtml = "#{escape_javascript(modal)}";
            var tempContainer = document.createElement("div");
            tempContainer.innerHTML = renderedHtml;
            document.getElementById('modals').appendChild(tempContainer.firstElementChild);
          JS
        end
      end

      # We use it for select2 search results
      format.json do
        if action_name == "index"
          collection = if result.model.is_a?(OpenStruct)
                         key = operation.to_s.split("::").first.underscore.pluralize
                         result.model[key]
          else
                         result.model
          end

          render json: {
            result: collection.map(&:select2_search_result),
            pagination: {
              more: collection.respond_to?(:next_page) && collection.next_page.present?
            }
          }
        elsif action_name.include?("destroy")
          if result.success?
            render json: { message: result.message }, status: :ok
          else
            render json: { error: result.error_message }, status: :unprocessable_entity
          end
        end
      end

        # TODO: auto-submit controller sends null request that could be handled only with format.any
        format.any do
          params = if result.model.is_a?(OpenStruct)
                     result.model.to_h
          else
                     key = operation.to_s.split("::").first.underscore.pluralize
                     { "#{key}": result.model }
          end
          render component.new(**params)
        end
      end
    end
  end

  # Render component without operation
  def render_component_only(component)
    render component.new
  end

  def check_authorization_is_called(result)
    skip_authorization if result[:pundit] || result["policy.run"] || result.failure?
    skip_policy_scope if result[:pundit_scope] || result.failure?
    result[:model]
  end
end
