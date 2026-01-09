# frozen_string_literal: true

class ShoppingList::Component::Form < Base::Component::Base
  def initialize(shopping_list:, form_id: nil, hide_actions: false)
    @shopping_list = shopping_list
    @form_id = form_id
    @hide_actions = hide_actions
  end
end
