Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get "schedules/:year/:week", to: "schedule#schedule"

  get "schedule", to: "schedule#get_user_schedule"

  get "employees", to: "employee#get_all"

  get "contracts/all", to: "contract#get_all"

  get "user-contracts", to: "contract#get_current_user_contracts"
end
