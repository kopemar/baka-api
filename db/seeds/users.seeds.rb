def generate_user_data(user)
  user.first_name = FFaker::Name.first_name
  user.last_name = FFaker::Name.last_name
  user.password = "12345678"
  user.birth_date = FFaker::Time.between("1950-01-01", "2000-01-01")
  user.email = "#{user.username}@example.com"
  user
end

5.times do |i|
  Employee.find_or_create_by!(username: "employee#{i}") do |user|
    generate_user_data(user)
  end
end