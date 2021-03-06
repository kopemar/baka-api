Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  mount_devise_token_auth_for 'User', at: 'api/v1/auth'

  namespace :api do
    namespace :v1 do
      get "periods/upcoming", to: "scheduling_period#upcoming"
      resources :specializations
      resources :scheduling_period, path: "periods"
      resources :shift_template, path: "templates"
      resources :organization
      resources :employee, path: "employees"
      resources :contract, path: "contracts"
      resources :shift, path: "shifts"

      # mount_devise_token_auth_for 'User', at: 'auth', :controllers => { sessions: 'users/sessions'}

      get "specializations/:id/calculate-contracts", to: "specializations#get_possible_contracts"
      get "specializations/:id/employees", to: "specializations#get_employees"

      get "periods/:id/calculations/schedule", to: "schedule#schedule"

      get "employees/:id/shifts", to: "employee#shifts"
      get "employees/:id/specializations", to: "employee#specializations"
      get "employees/:id/contracts", to: "employee#contracts"

      get "contracts", to: "contract#get_current_user_contracts"

      get "shift/:id/schedules", to: "shift#get_possible_schedules"

      #post "shifts", to: "shift#assign_shift"

      delete "shift/:id/schedule", to: "shift#remove_from_schedule"

      get "organization/:id/employees", to: "organization#get_employees"

      post "templates/:id/specialized", to: "shift_template#create_specialized_template"
      get "templates/:id/calculate-specializations", to: "shift_template#get_specializations"

      get "templates/:id/employees", to: "shift_template#employees"

      get "periods/:id/units", to: "scheduling_unit#in_period"

      get "periods/:id/calculate-shift-times", to: "scheduling_period#calculate_shift_times"

      get "periods/:id/calculate-period-days", to: "scheduling_period#get_unit_dates_for_period"

      post "periods/:id/shift-templates", to: "scheduling_period#generate_shift_templates"

      post "periods/:id/templates", to: "scheduling_period#generate_shift_templates"

      post "periods/:id/generate-schedule", to: "scheduling_period#generate_schedule"

      post "users/fcm-token", to: "user#save_fcm_token"
    end
  end
end
