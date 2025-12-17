# frozen_string_literal: true

class Shared::TitleRow::Component::Show < Base::Component::Base
  def initialize(title:, button_text: nil, button_path: nil, button_class: "btn btn-primary page-header-btn", button_data: {})
    @title = title
    @button_text = button_text
    @button_path = button_path
    @button_class = button_class
    @button_data = button_data
  end

  def show_button?
    @button_text.present?
  end

  def button_is_link?
    @button_path.present? && @button_data.empty?
  end
end
