class V1::FriendshipRequests < Grape::API
  resource :friendship_requests do
    desc "Get all friendship requests",
         tags: [ "Friendship Requests" ],
         success: Entities::FriendshipRequest
    get do
      result = run_operation FriendshipRequest::Operation::Index
      present :incoming_requests, result.incoming_requests, with: Entities::FriendshipRequest
      present :outgoing_requests, result.outgoing_requests, with: Entities::FriendshipRequest
    end

    desc "Create a friendship request",
         tags: [ "Friendship Requests" ],
         success: Entities::FriendshipRequest
    params do
      requires :friendship_request, type: Hash do
         requires :accepter_id, type: Integer, desc: "ID of the user to send request to"
      end
    end
    post do
      result = run_operation FriendshipRequest::Operation::Create
      present result, with: Entities::FriendshipRequest
    end

    route_param :id do
      desc "Accept a friendship request",
           tags: [ "Friendship Requests" ],
           success: Entities::FriendshipRequest
      put do
        result = run_operation FriendshipRequest::Operation::Update
        present result, with: Entities::FriendshipRequest
      end

      desc "Decline/Cancel a friendship request",
           tags: [ "Friendship Requests" ]
      delete do
        run_operation FriendshipRequest::Operation::Destroy
        status 204
      end
    end
  end
end
