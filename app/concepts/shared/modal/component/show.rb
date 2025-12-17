# frozen_string_literal: true

class Shared::Modal::Component::Show < Base::Component::Base
  def initialize(id:, title:, size: "md")
    @id = id
    @title = title
    @size = size
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
end
