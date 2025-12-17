# frozen_string_literal: true

class Shared::Modal::Component::Show < Base::Component::Base
  def initialize(id:, title:, size: "md", type: nil)
    @id = id
    @title = title
    @size = size
    @type = type
  end

  def modal_size_class
    case @size
    when "sm"
      "modal-sm"
    when "lg"
      "modal-lg"
    when "xl"
      "modal-xl"
    else
      ""
    end
  end

  def modal_type_class
    return "" if @type.blank?
    "form-modal" if @type == "form"
  end
end
