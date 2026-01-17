# frozen_string_literal: true

class ShoppingListMembership::Operation::Destroy < Base::Operation::Base
  def perform!(params:, current_user:)
    membership = ShoppingListUser.find(params[:id])
    shopping_list = membership.shopping_list

    # Can only leave your own membership
    unless membership.user_id == current_user.id
      add_error(:base, I18n.t("shopping_lists.leave.not_member"))
      invalid!
      self.redirect_path = "/shopping_lists"
      return
    end

    # Can't leave if you're the owner
    if shopping_list.owned_by?(current_user)
      add_error(:base, I18n.t("shopping_lists.leave.owner_cannot_leave"))
      invalid!
      self.redirect_path = "/shopping_lists/#{shopping_list.id}"
      return
    end

    authorize! shopping_list, :show?

    membership.destroy!

    self.model = shopping_list
    self.redirect_path = "/shopping_lists"
    notice I18n.t("shopping_lists.leave.success")
  end
end
