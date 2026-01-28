# frozen_string_literal: true

class Base::Component::Button < Base::Component::Base
  def initialize(type:, path: nil, text: nil, modal_id: nil, **options)
    @type = type
    @path = path
    @text = text
    @modal_id = modal_id
    @options = options
  end

  private

  def icon_class
    case @type
    when :show then "bi-eye"
    when :edit then "bi-pencil-square"
    when :delete then "bi-trash"
    when :reject then "bi-x-lg"
    when :external_link then "bi-box-arrow-up-right"
    when :accept then "bi-check-lg"
    else @options[:icon] || ""
    end
  end

  def btn_class
    base = "btn"
    variant = case @type
    when :delete, :reject then "btn-danger"
    when :link, :external_link then "btn-link"
    when :accept then "btn-success"
    else "btn-primary"
    end

    [ base, variant, @options[:class] ].compact.join(" ")
  end

  def html_options
    opts = @options.except(:class)
    opts[:class] = btn_class

    if @modal_id
      opts[:data] ||= {}
      opts[:data][:bs_toggle] = "modal"
      opts[:data][:bs_target] = "##{@modal_id}"
      opts[:type] = "button" unless @path
    end

    if opts[:data]
      # Ensure symbol keys for the data hash if it exists
      opts[:data] = opts[:data].symbolize_keys

      if opts[:data][:turbo_method]
        opts[:data][:turbo_prefetch] = "false"
      end
    end

    opts
  end
end
