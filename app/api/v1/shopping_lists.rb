class V1::ShoppingLists < Grape::API
  resource :shopping_lists do
    desc "Get all shopping lists",
         tags: [ "Shopping Lists" ],
         success: Entities::ShoppingList
    get do
      result = run_operation ShoppingList::Operation::Index
      body = {
        shopping_lists: Entities::ShoppingList.represent(result.shopping_lists),
        pending_invitations: Entities::ShoppingListInvitation.represent(result.pending_invitations)
      }
      present body
    end

    desc "Create a shopping list",
         tags: [ "Shopping Lists" ],
         success: Entities::ShoppingList
    params do
      requires :shopping_list, type: Hash do
        requires :name, type: String, desc: "Name of the shopping list"
      end
    end
    post do
      result = run_operation ShoppingList::Operation::Create
      present result, with: Entities::ShoppingList
    end

    route_param :id do
      desc "Get a shopping list",
           tags: [ "Shopping Lists" ],
           success: Entities::ShoppingList
      get do
        result = run_operation ShoppingList::Operation::Show
        present result.shopping_list, with: Entities::ShoppingList
      end

      desc "Update a shopping list",
           tags: [ "Shopping Lists" ],
           success: Entities::ShoppingList
      params do
        requires :shopping_list, type: Hash do
          requires :name, type: String, desc: "Name of the shopping list"
        end
      end
      put do
        result = run_operation ShoppingList::Operation::Update
        present result, with: Entities::ShoppingList
      end

      desc "Delete a shopping list",
           tags: [ "Shopping Lists" ]
      delete do
        run_operation ShoppingList::Operation::Destroy
        status 204
      end
    end
  end
end
