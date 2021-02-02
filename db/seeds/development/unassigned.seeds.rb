# FactoryBot.define do
#   factory :template, class: ShiftTemplate do
#     start_time { FFaker::Time.between(Date.today, 2.week.from_now).beginning_of_hour }
#     end_time { rand(1..10).hours.after(start_time) }
#   end
# end
#
# FactoryBot.create_list(:template, 100)