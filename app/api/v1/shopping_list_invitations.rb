class V1::ShoppingListInvitations < Grape::API
  resource :shopping_list_invitations do
    desc "Create a shopping list invitation",
         tags: [ "Shopping List Invitations" ],
         success: Entities::ShoppingListInvitation
    params do
      requires :shopping_list_id, type: Integer, desc: "ID of the shopping list"
      requires :invitee_id, type: Integer, desc: "ID of the user to invite"
    end
    post do
      params[:shopping_list_invitation] = {
        shopping_list_id: params[:shopping_list_id],
        invitee_id: params[:invitee_id]
      }
      result = run_operation ShoppingListInvitation::Operation::Create
      present result, with: Entities::ShoppingListInvitation
    end

    route_param :id do
      desc "Accept a shopping list invitation",
           tags: [ "Shopping List Invitations" ],
           success: Entities::ShoppingListInvitation
      put do
        result = run_operation ShoppingListInvitation::Operation::Update
        present result, with: Entities::ShoppingListInvitation
      end

      desc "Decline/Cancel a shopping list invitation",
           tags: [ "Shopping List Invitations" ]
      delete do
        run_operation ShoppingListInvitation::Operation::Destroy
        status 204
      end
    end
  end
end
