Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get "schedules", to: "schedule#schedule"

  get "shifts", to: "shift#get_user_schedule"

  get "employees", to: "employee#get_all"

  get "contracts", to: "contract#get_current_user_contracts"

end
