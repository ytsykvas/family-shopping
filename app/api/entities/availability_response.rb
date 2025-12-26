class Entities::AvailabilityResponse < Grape::Entity
  expose :available, documentation: { type: "Boolean", desc: "Whether the value is available" }
  expose :message, documentation: { type: "String", desc: "Human-readable message" }
end
