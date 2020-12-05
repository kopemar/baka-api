ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
Dir[Rails.root.join('test/factory/*.rb')].each do |f|
  p f
  require f
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

end
