Dir[Rails.root.join('db/seeds/*.rb')].each do |f|
  require f
end

# contract1 = EmploymentContract.create!(
#     start_date: "2020-01-01",
#     end_date: "2020-10-12",
#     work_load: "1",
#     working_days: [1, 2, 3, 5, 6, 7]
# )
# # contract1.employee = employee1
# # contract1.save!
#
# contract2 = EmploymentContract.create!(
#     start_date: "2020-01-01",
#     end_date: "2021-10-12",
#     work_load: "1",
#     working_days: [1, 2, 3, 5, 6, 7]
# )
#
# contract2.employee = employee2
# contract2.save!
#
# demand = Hash.new
# demand[0] = Hash.new
# demand[0][0] = 1
#
# WeeklyDemand.find_or_create_by!(week: 5) do |d|
#   d.demand = demand
# end