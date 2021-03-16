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
end
