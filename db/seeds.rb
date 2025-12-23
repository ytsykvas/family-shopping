# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load environment-specific seed files
seed_file = Rails.root.join("db", "seeds", "#{Rails.env}.rb")
if seed_file.exist?
  puts "Loading #{Rails.env} seed data..."
  load seed_file
else
  puts "No seed file found for #{Rails.env} environment."
end
