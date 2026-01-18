module Entities
  class Token < Grape::Entity
    expose :token, documentation: { type: "String", desc: "JWT Token" }
    expose :user_id, documentation: { type: "Integer", desc: "User ID" }
    expose :email, documentation: { type: "String", desc: "User Email" }
  end
end
