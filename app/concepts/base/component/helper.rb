# frozen_string_literal: true

module Base::Component::Helper
  # def header(title:, &block)
  #   render(Base::Component::Header.new(title:), &block)
  # end

  # def sub_header(title:, &block)
  #   render(Base::Component::SectionHeader.new(title:), &block)
  # end

  # def alert(text: nil, type: :info, dismissible: false, options: {}, &block)
  #   render(Base::Component::Bootstrap::Alert.new(text:, type:, dismissible:, options:), &block)
  # end

  # def accordion(id: nil, title:, open: false, &block)
  #   render(Base::Component::Bootstrap::Accordion.new(id:, title:, open:), &block)
  # end

  # def modal(header_text:, size: "lg", parent_modal_id: nil, modal_id: nil, auto_show: true, options: {}, &block)
  #   render(Base::Component::Bootstrap::Modal.new(header_text:, size:, parent_modal_id:, modal_id:, options:, auto_show:), &block)
  # end

  # def icon(name, options = {})
  #   classes = [ "bi", "bi-#{name}" ]
  #   classes << options[:class] if options[:class]
  #   content_tag(:i, nil, class: classes.join(" "))
  # end

  # def allowed?(record, query, policy: Pundit.policy!(@attrs[:current_user], record))
  #   policy.public_send(query)
  # end
end
