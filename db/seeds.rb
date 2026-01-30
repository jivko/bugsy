# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

user = User.find_or_initialize_by(email_address: "user@example.com")
if user.new_record?
  user.assign_attributes(name: "Admin User", password: "1", role: :admin)
  user.save!(validate: false)
end

member = User.find_or_initialize_by(email_address: "member@example.com")
if member.new_record?
  member.assign_attributes(name: "Member User", password: "1", role: :member)
  member.save!(validate: false)
end

project = Project.find_or_create_by!(name: "Demo Project") do |p|
  p.description = "A demo project for testing"
  p.owner = user
end
project.project_memberships.find_or_create_by!(user: user)
project.project_memberships.find_or_create_by!(user: member)
