module Entities
  class User < Grape::Entity
    expose :id
    expose :email
    expose :nickname
    expose :name
  end
end
