Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  get "periods/:id/calculations/schedule", to: "schedule#schedule"

  get "shifts", to: "shift#get_shifts"

  get "employees", to: "employee#get_all"

  get "contracts", to: "contract#get_current_user_contracts"

  get "shift/:id/schedules", to: "shift#get_possible_schedules"

  post "shifts", to: "shift#assign_shift"

  delete "shift/:id/schedule", to: "shift#remove_from_schedule"

  post "templates", to: "shift_template#create_template"

  get "templates", to: "shift_template#get_templates"

  get "templates/:id/employees", to: "shift_template#get_employees"

  get "periods", to: "scheduling_period#all"

  get "periods/:id", to: "scheduling_period#by_id"

  get "periods/:id/units", to: "scheduling_unit#in_period"

  get "periods/:id/calculations/shift-times", to: "scheduling_period#calculate_shift_times"

  get "periods/:id/calculations/period-days", to: "scheduling_period#get_unit_dates_for_period"

  post "periods/:id/shift-templates", to: "scheduling_period#generate_shift_templates"

  post "periods/:id/calculations/generate-schedule", to: "scheduling_period#generate_schedule"
end
