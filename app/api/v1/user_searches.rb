class V1::UserSearches < Grape::API
  resource :user_searches do
    desc "Search users",
         tags: [ "User Searches" ],
         success: Entities::User
    params do
      requires :query, type: String, desc: "Search query"
    end
    get do
      result = run_operation UserSearches::Operation::Index
      present result[:users], with: Entities::User
    end
  end
end
