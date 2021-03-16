require 'test_helper'

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

  test "Demand Fulfill Constraint 1 (easy)" do
    o = generate_organization

    user = FactoryBot.create(:manager, organization: o)
    @auth_tokens = auth_tokens_for_user(user)

    16.times do
      employee_active_contract
    end

    period = FactoryBot.create(:scheduling_period, organization_id: o.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => period.id,
            :working_days => [1],
            :start_time => "08:00",
            :end_time => "18:30",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 4
        }
    )

    assert_equal 4, templates.length

    5.times do |i|
      post "/periods/#{period.id}/calculations/generate-schedule",
           headers: @auth_tokens,
           params: {
               :priorities => {
                   :no_empty_shifts => 0,
                   :demand_fulfill => 100
               }
           }
      assert_response(:success)
      response_body = response.parsed_body.deep_symbolize_keys

      Rails.logger.debug "💌 #{i} -> #{response_body}"
      assert_equal 0, response_body[:violations][:sanction]
    end
  end
end
