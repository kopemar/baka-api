require 'test_helper'

class SubmitScheduleTest < ActionDispatch::IntegrationTest
  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'email' and 'password'.
    post '/auth/sign_in/',
         params: {username: user[:username], password: ""},
         as: :json
    # The three categories below are the ones you need as authentication headers.
    response.headers.slice('client', 'access-token', 'uid', 'token-type', 'expiry')
  end

  test "Submit schedule" do
    org = generate_organization

    manager = FactoryBot.create(:manager, organization: org)
    manager_tokens = auth_tokens_for_user(manager)

    employee = employee_active_contract(org)
    employee_tokens = auth_tokens_for_user(employee)

    period = FactoryBot.create(:scheduling_period, organization: org)

    get "/shifts", headers: employee_tokens
    assert_response(:success)
    shifts = response.parsed_body.deep_symbolize_keys

    assert_equal 0, shifts[:shifts].length

    generate_shift_templates(period, manager_tokens)
    generate_schedule_basic(period, manager_tokens)

    get "/shifts", headers: employee_tokens
    assert_response(:success)
    shifts = response.parsed_body.deep_symbolize_keys

    assert_equal 0, shifts[:shifts].length

    post "/periods/#{period.id}/submit", headers: manager_tokens

    Rails.logger.debug "🐿 shifts: #{Shift.all.to_a}"

    get "/shifts", headers: employee_tokens
    assert_response(:success)
    shifts = response.parsed_body.deep_symbolize_keys

    assert_equal 5, shifts[:shifts].length
  end
end