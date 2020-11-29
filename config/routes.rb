Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get "schedules", to: "schedule#get_all"

  get "employees", to: "employee#get_all"

  get "contracts", to: "contract#get_all"
end
