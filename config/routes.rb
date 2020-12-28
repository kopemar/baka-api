Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get "generate-schedule", to: "schedule#schedule"

  get "shifts", to: "shift#get_shifts"

  get "employees", to: "employee#get_all"

  get "contracts", to: "contract#get_current_user_contracts"

  get "shift/:id/schedules", to: "shift#get_possible_schedules"

  post "shift/:id/schedule", to: "shift#assign_shift"

  delete "shift/:id/schedule", to: "shift#remove_from_schedule"
end
