module V1
  class WishlistItems < Grape::API
    resource :wishlist_items do
      desc "Get all wishlist items",
           tags: [ "Wishlist Items" ],
           success: Entities::WishlistItem
      get do
        result = run_operation ::WishlistItems::Operation::Index
        present result.wishlist_items, with: Entities::WishlistItem
      end

      desc "Create a wishlist item",
           tags: [ "Wishlist Items" ],
           success: Entities::WishlistItem
      params do
        requires :wishlist_item, type: Hash do
          requires :title, type: String, desc: "Title of the item"
          optional :description, type: String, desc: "Description of the item"
          optional :url, type: String, desc: "URL of the item"
          optional :price, type: Float, desc: "Price of the item"
          optional :currency, type: String, desc: "Currency of the price"
        end
      end
      post do
        result = run_operation ::WishlistItems::Operation::Create
        present result, with: Entities::WishlistItem
      end

      route_param :id do
        desc "Get a user's wishlist",
             tags: [ "Wishlist Items" ],
             detail: "Returns the wishlist items for the user with the given ID",
             success: Entities::WishlistItem
        get do
          result = run_operation ::WishlistItems::Operation::Show
          present result.wishlist_items, with: Entities::WishlistItem
        end

        desc "Update a wishlist item",
             tags: [ "Wishlist Items" ],
             success: Entities::WishlistItem
        params do
          requires :wishlist_item, type: Hash do
            optional :title, type: String, desc: "Title of the item"
            optional :description, type: String, desc: "Description of the item"
            optional :url, type: String, desc: "URL of the item"
            optional :price, type: Float, desc: "Price of the item"
            optional :currency, type: String, desc: "Currency of the price"
          end
        end
        put do
          result = run_operation ::WishlistItems::Operation::Update
          present result, with: Entities::WishlistItem
        end

        desc "Delete a wishlist item",
             tags: [ "Wishlist Items" ]
        delete do
          run_operation ::WishlistItems::Operation::Destroy
          status 204
        end

        desc "Book a wishlist item",
             tags: [ "Wishlist Items" ]
        post :book do
          run_operation ::WishlistItems::Operation::Book
          status 200
        end

        desc "Unbook a wishlist item",
             tags: [ "Wishlist Items" ]
        delete :unbook do
          run_operation ::WishlistItems::Operation::Unbook
          status 200
        end
      end
    end
  end
end
