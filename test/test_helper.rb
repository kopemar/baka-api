ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
Dir[Rails.root.join('test/factory/*.rb')].each do |f|
  p f
  require f
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # todo stack overflow credit
  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'username' and 'password'.
    post '/auth/sign_in/',
         params: {username: user[:username], password: ""},
         as: :json
    # The three categories below are the ones you need as authentication headers.
    response.headers.slice('client', 'access-token', 'uid', 'token-type', 'expiry')
  end

  def generate_shift_templates(period, auth_tokens)
    post "/periods/#{period.id}/templates",
         params: {
             working_days: [1, 2, 3, 4, 5],
             start_time: "08:00",
             end_time: "16:30",
             shift_hours: 8,
             break_minutes: 30,
             per_day: 1
         },
         headers: auth_tokens

    response.parsed_body.deep_symbolize_keys[:data]
  end
end
