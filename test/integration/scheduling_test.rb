class SchedulingTest < ActionDispatch::IntegrationTest
  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'email' and 'password'.
    post '/auth/sign_in/',
         params: {username: user[:username], password: ""},
         as: :json
    # The three categories below are the ones you need as authentication headers.
    response.headers.slice('client', 'access-token', 'uid', 'token-type', 'expiry')
  end

  def generate_period(auth_tokens, org)
    period = FactoryBot.create(:scheduling_period, organization: org)
    post "/periods/#{period.id}/shift-templates",
         params: {
             working_days: [1, 2, 3, 4, 5],
             start_time: "08:00",
             end_time: "18:30",
             shift_hours: 8,
             break_minutes: 30,
             per_day: 4
         },
         headers: @auth_tokens

    assert_response :success
    SchedulingPeriod.where(id: period.id).first
  end

  test "Init" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    period = generate_period(@auth_tokens, org)

    get "/periods/#{period.id}/calculations/schedule",
        headers: @auth_tokens

    assert_response :success

  end
end
