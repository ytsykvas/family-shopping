# frozen_string_literal: true

class Shared::Pagination::Component::Show < Base::Component::Base
  def initialize(collection:, param_name: :page)
    @collection = collection
    @param_name = param_name
  end

  def render?
    @collection.respond_to?(:total_pages) && @collection.total_pages > 1
  end

  def before_render
    return unless render?

    # To make it simple properly, we can calculate values here and pass to template
    @current_page = @collection.current_page
    @total_pages = @collection.total_pages
    @remote = false

    # Kaminari's paginator needs options.
    @paginator = Kaminari::Helpers::Paginator.new(
      self,
      window: 2,
      outer_window: 1,
      param_name: @param_name,
      params: params,
      current_page: @current_page,
      total_pages: @total_pages,
      per_page: @collection.limit_value,
      remote: false
    )
  end

  # Proxy methods required by Kaminari's Paginator
  def params
    helpers.params
  end

  def url_for(options)
    if options.is_a?(Hash)
      helpers.url_for(params.to_unsafe_h.merge(options))
    else
      helpers.url_for(options)
    end
  end

  def output_buffer
    ActionView::OutputBuffer.new
  end
end
