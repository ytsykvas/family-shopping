module Entities
  class Friend < Grape::Entity
    expose :id
    expose :email
    expose :nickname
    expose :name
  end
end
