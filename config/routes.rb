Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get "periods/:id/calculations/schedule", to: "schedule#schedule"

  get "shifts", to: "shift#get_shifts"

  get "employees", to: "employee#get_all"

  get "contracts", to: "contract#get_current_user_contracts"

  get "shift/:id/schedules", to: "shift#get_possible_schedules"

  post "shifts", to: "shift#assign_shift"

  delete "shift/:id/schedule", to: "shift#remove_from_schedule"

  post "templates", to: "shift_template#create_template"

  get "templates", to: "shift_template#get_templates"

  get "periods", to: "scheduling_period#all"

  get "units/:id", to: "scheduling_unit#in_period"

  get "periods/:id/calculations/shift-times", to: "scheduling_period#calculate_shift_times"

  get "periods/:id/calculations/period-days", to: "scheduling_period#get_unit_dates_for_period"

  post "periods/:id/shift-templates", to: "scheduling_period#generate_shift_templates"
end
