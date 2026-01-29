module V1
  class Recipes < Grape::API
    resource :recipes do
      desc "Get all recipes",
           tags: [ "Recipes" ],
           success: Entities::Recipe
      get do
        result = run_operation ::Recipe::Operation::Index
        present result, with: Entities::Recipe
      end

      desc "Create a recipe",
           tags: [ "Recipes" ],
           success: Entities::Recipe
      params do
        requires :recipe, type: Hash do
          requires :name, type: String, desc: "Name of the recipe"
          optional :description, type: String, desc: "Description of the recipe"
          optional :ingredients_attributes, type: Array do
            optional :id, type: String, desc: "ID (for update/destroy)"
            requires :content, type: String, desc: "Content (e.g. 'Eggs 2pcs')"
            optional :_destroy, type: Boolean, desc: "Destroy flag"
          end
        end
      end
      post do
        result = run_operation ::Recipe::Operation::Create
        present result, with: Entities::Recipe
      end

      route_param :id do
        desc "Get a recipe",
             tags: [ "Recipes" ],
             success: Entities::Recipe
        get do
          result = run_operation ::Recipe::Operation::Show
          present result, with: Entities::Recipe
        end

        desc "Update a recipe",
             tags: [ "Recipes" ],
             success: Entities::Recipe
        params do
          requires :recipe, type: Hash do
            optional :name, type: String, desc: "Name of the recipe"
            optional :description, type: String, desc: "Description of the recipe"
            optional :ingredients_attributes, type: Array do
              optional :id, type: String, desc: "ID"
              optional :content, type: String, desc: "Content"
              optional :_destroy, type: Boolean, desc: "Destroy"
            end
          end
        end
        put do
          result = run_operation ::Recipe::Operation::Update
          present result, with: Entities::Recipe
        end

        desc "Delete a recipe",
             tags: [ "Recipes" ]
        delete do
          run_operation ::Recipe::Operation::Destroy
          status 204
        end

        desc "Add recipe ingredients to shopping list",
             tags: [ "Recipes" ]
        params do
          optional :ingredient_ids, type: Array[Integer], desc: "IDs of ingredients to add"
        end
        post :add_to_shopping_list do
          run_operation ::Recipe::Operation::AddToShoppingList
          status 200
        end
      end
    end
  end
end
