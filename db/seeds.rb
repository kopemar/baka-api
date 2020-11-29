# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# Employee.create(first_name: "Jan", last_name: "Nowakovic", username: "jannovak")
#
def generate_user_data(user)
  user.first_name = FFaker::Name.first_name
  user.last_name = FFaker::Name.last_name
  user.password = "12345678"
  user.birth_date = "2000-01-01"
  user.email = "#{user.username}@example.com"
  user
end

Employee.find_or_create_by!(username: "heya") do |user|
  generate_user_data(user)
end

Employee.find_or_create_by!(username: "john-doe") do |user|
  generate_user_data(user)
end

Employee.find_or_create_by!(username: "employee") do |user|
  generate_user_data(user)
end

Employee.find_or_create_by!(username: "employee2") do |user|
  generate_user_data(user)
end

Employee.find_or_create_by!(username: "employee3") do |user|
  generate_user_data(user)
end
