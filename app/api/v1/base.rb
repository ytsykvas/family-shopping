class V1::Base < Grape::API
  version "v1", using: :path

  helpers AuthenticationHelper

  rescue_from Pundit::NotAuthorizedError do |e|
    error!({ error: "You are not authorized to perform this action" }, 403)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    error!({ error: "Result not found" }, 404)
  end

  before do
    authenticate_user! unless route.settings[:public]
  end

  mount V1::Users
  mount V1::ShoppingLists
  mount V1::ShoppingListInvitations
  mount V1::ShoppingListMemberships
  mount V1::Friends
  mount V1::FriendshipRequests
  mount V1::UserSearches
end
