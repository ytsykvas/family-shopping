# frozen_string_literal: true

require "ostruct"

module OperationsMethods
  include ActionView::Helpers::JavaScriptHelper
  extend ActiveSupport::Concern

  protected

  def endpoint(operation_or_component, component = nil, **component_params)
    # Check if first argument is a component (has no 'call' method)
    if component.nil? && !operation_or_component.respond_to?(:call)
      # Direct component rendering without operation
      render_component_only(operation_or_component, **component_params)
    else
      # Operation + Component flow
      operation = operation_or_component
      result = operation.call(params:, current_user:)

      check_authorization_is_called result

      respond_to do |format|
        format.html do
          if action_name == "create" || action_name == "update" || action_name.include?("destroy")
            path = result.redirect_path || public_send("#{controller_name}_path")
            flash_params = {}
            flash_params[:notice] = result.message if result.message.present?
            flash_params[:alert] = result.error_message if result.error_message.present?
            redirect_to path, **flash_params
          elsif action_name == "index"
            params = if result.model.is_a?(OpenStruct)
                       result.model.to_h
            else
                       key = operation.to_s.split("::").first.underscore.pluralize
                       { "#{key}": result.model }
            end

            render component.new(**params)
          elsif action_name == "edit" || action_name == "new" || action_name == "show"
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

      format.turbo_stream do
        if result.success? && (action_name == "create" || action_name == "update" || action_name.include?("destroy"))
          path = result.redirect_path || public_send("#{controller_name}_path")
          flash[:notice] = result.message if result.message.present?
          redirect_to path
          return
        end

        if result.failure?
          @error_message = result.error_message
          response.status = :unprocessable_entity
        end

        # Only set instance variables/params if we are NOT redirecting
        params = if result.model.is_a?(OpenStruct)
                   result.model.to_h
        else
                   key = operation.to_s.split("::").first.underscore
                   key = key.pluralize if action_name == "index"
                   { "#{key}": result.model }
        end

        # Set instance variables for legacy view compatibility (if any)
        if result.model.is_a?(OpenStruct)
          result.model.to_h.each { |k, v| instance_variable_set("@#{k}", v) }
        else
          @model = result.model
        end

        if component
          # Ensure index/show render as HTML so Turbo processes them as page visits/refreshes
          opts = {}
          opts[:content_type] = "text/html" if action_name.in?(%w[index show])
          render component.new(**params), **opts
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
  def render_component_only(component, **params)
    render component.new(**params)
  end

  # Endpoint for partial/component rendering (e.g., for AJAX/Turbo Stream updates)
  # Can accept either a partial path string or a component class
  def endpoint_partial(operation, partial_or_component, target_id: nil)
    result = operation.call(params: params, current_user: current_user)
    check_authorization_is_called result

    respond_to do |format|
      format.turbo_stream do
        results_html = if partial_or_component.is_a?(String)
          # Render partial
          render_to_string(
            partial: partial_or_component,
            locals: result.model.is_a?(Hash) ? result.model : { model: result.model },
            layout: false
          )
        else
          # Render component
          component_params = result.model.is_a?(Hash) ? result.model : { model: result.model }
          render_to_string(partial_or_component.new(**component_params), layout: false)
        end

        if target_id.present?
          render turbo_stream: turbo_stream.replace(target_id, results_html)
        else
          render turbo_stream: results_html
        end
      end
      format.html do
        if partial_or_component.is_a?(String)
          # Render partial
          render partial: partial_or_component,
                 locals: result.model.is_a?(Hash) ? result.model : { model: result.model },
                 layout: false
        else
          # Render component
          component_params = result.model.is_a?(Hash) ? result.model : { model: result.model }
          render partial_or_component.new(**component_params), layout: false
        end
      end
    end
  end

  def check_authorization_is_called(result)
    skip_authorization if result[:pundit] || result["policy.run"] || result.failure?
    skip_policy_scope if result[:pundit_scope] || result.failure?
    result[:model]
  end
end
