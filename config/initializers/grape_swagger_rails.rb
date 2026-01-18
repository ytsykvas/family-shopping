GrapeSwaggerRails.options.url = "/api/swagger_doc"
GrapeSwaggerRails.options.app_name = "Family Shopping API"
GrapeSwaggerRails.options.app_url = "/"

# Provide API Key configuration for "Authorize" button
GrapeSwaggerRails.options.api_auth = "bearer"
GrapeSwaggerRails.options.api_key_name = "Authorization"
GrapeSwaggerRails.options.api_key_type = "header"

# UI Configuration
GrapeSwaggerRails.options.doc_expansion = "list"
GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
end
