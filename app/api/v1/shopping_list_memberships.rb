class V1::ShoppingListMemberships < Grape::API
  resource :shopping_list_memberships do
    route_param :id do
      desc "Leave a shopping list",
           tags: [ "Shopping List Memberships" ]
      delete do
        run_operation ShoppingListMembership::Operation::Destroy
        status 204
      end
    end
  end
end
