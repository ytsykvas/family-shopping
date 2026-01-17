class V1::Friends < Grape::API
  resource :friends do
    desc "Get all friends",
         tags: [ "Friends" ],
         success: Entities::Friend
    get do
      result = run_operation Friends::Operation::Index
      present result.friends, with: Entities::Friend
    end

    route_param :id do
      desc "Remove a friend",
           tags: [ "Friends" ]
      delete do
        run_operation Friends::Operation::Destroy
        status 204
      end
    end
  end
end
