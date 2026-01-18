class ApiRoot < Grape::API
  format :json
  prefix :api

  mount V1::Base

  add_swagger_documentation(
    api_version: "v1",
    hide_documentation_path: true,
    mount_path: "/swagger_doc",
    hide_format: true,
    info: {
      title: "Family Shopping API",
      description: "API for Family Shopping application"
    },
    security_definitions: {
      Bearer: {
        type: "apiKey",
        name: "Authorization",
        in: "header"
      }
    },
    security: [
      { Bearer: [] }
    ],
    models: [
      Entities::AvailabilityResponse
    ]
  )
end
