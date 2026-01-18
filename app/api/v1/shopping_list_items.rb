class V1::ShoppingListItems < Grape::API
  resource :shopping_lists do
    route_param :shopping_list_id do
      resource :items do
        desc "Get all items for a shopping list",
             tags: [ "Shopping List Items" ],
             success: Entities::ShoppingListItem
        get do
          result = run_operation ShoppingListItem::Operation::Index
          present result.items, with: Entities::ShoppingListItem
        end

        desc "Create an item",
             tags: [ "Shopping List Items" ],
             success: Entities::ShoppingListItem
        params do
          requires :shopping_list_item, type: Hash do
            requires :name, type: String, desc: "Name of the item"
          end
        end
        post do
          result = run_operation ShoppingListItem::Operation::Create
          present result, with: Entities::ShoppingListItem
        end

        route_param :id do
          desc "Update an item",
               tags: [ "Shopping List Items" ],
               success: Entities::ShoppingListItem
          params do
            requires :shopping_list_item, type: Hash do
              optional :name, type: String, desc: "Name of the item"
              optional :status, type: String, values: %w[pending done], desc: "Status of the item"
            end
          end
          patch do
            result = run_operation ShoppingListItem::Operation::Update
            present result, with: Entities::ShoppingListItem
          end

          desc "Delete an item",
               tags: [ "Shopping List Items" ]
          delete do
            run_operation ShoppingListItem::Operation::Destroy
            status 204
          end
        end
      end
    end
  end
end
