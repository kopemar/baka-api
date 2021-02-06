require 'test_helper'

class SchedulingPeriodControllerTest < ActionDispatch::IntegrationTest

  test "Computations - create shift - too short time" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    p @auth_tokens

    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "17:30",
            shift_hours: 8,
            break_minutes: 30,
            per_day: 1
        },
        headers: @auth_tokens
    assert_response(400)
  end

  test "Computations - create shift - too long time" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    p @auth_tokens

    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "16:30",
            shift_hours: 9,
            break_minutes: 30,
            per_day: 1
        },
        headers: @auth_tokens
    assert_response(400)
  end

  test "Computations - create shift - too long more shifts" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    p @auth_tokens

    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "17:01",
            shift_hours: 4,
            break_minutes: 30,
            per_day: 2
        },
        headers: @auth_tokens
    assert_response(400)
  end

  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'email' and 'password'.
    post '/auth/sign_in/',
         params: {username: user[:username], password: ""},
         as: :json
    # The three categories below are the ones you need as authentication headers.
    response.headers.slice('client', 'access-token', 'uid', 'token-type', 'expiry')
  end

  test "Computations - create one shift" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    p @auth_tokens

    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "16:30",
            shift_hours: 8,
            break_minutes: 30,
            per_day: 1
        },
        headers: @auth_tokens
    assert_response :success
    assert_equal(1, response.parsed_body["times"].length)
    #assert_equal("08:00".to_time, response.parsed_body["times"].first["start_time"])
    assert_equal("16:30".to_time, response.parsed_body["times"].first["end_time"])
  end

  test "Computations - create two shifts" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "18:30",
            shift_hours: 8,
            break_minutes: 30,
            per_day: 2
        },
        headers: @auth_tokens
    assert_response :success
    times = response.parsed_body["times"]
    assert_equal(2, times.length)

    assert_empty times.select { |time| time["start_time"].to_time == "09:00".to_time }
    assert_nil times.select { |time| time["start_time"].to_time == "09:00".to_time }.first

    assert_not_nil times.select { |time| time["start_time"].to_time == "08:00".to_time }.first
    assert_not_empty times.select { |time| time["end_time"].to_time == "16:30".to_time }
    assert_not_empty times.select { |time| time["start_time"].to_time == "10:00".to_time }
    assert_not_nil times.select { |time| time["end_time"].to_time == "18:30".to_time }.first
  end

  test "Computations - create three shifts" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "18:30",
            shift_hours: 8,
            break_minutes: 30,
            per_day: 3
        },
        headers: @auth_tokens
    assert_response :success
    times = response.parsed_body["times"]
    assert_equal(3, times.length)
    p times

    assert_not_nil times.select { |time| time["start_time"].to_time == "09:00".to_time }.first
    assert_not_nil times.select { |time| time["end_time"].to_time == "17:30".to_time }.first
    assert_not_nil times.select { |time| time["start_time"].to_time == "08:00".to_time }.first
    assert_not_empty times.select { |time| time["end_time"].to_time == "16:30".to_time }
    assert_not_empty times.select { |time| time["start_time"].to_time == "10:00".to_time }
    assert_not_nil times.select { |time| time["end_time"].to_time == "18:30".to_time }.first
  end

  test "Computations - create more shifts" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)
    get "/periods/1/calculations/shift-times",
        params: {
            start_time: "08:00",
            end_time: "18:30",
            shift_hours: 8,
            break_minutes: 30,
            per_day: 4
        },
        headers: @auth_tokens
    assert_response :success
    times = response.parsed_body["times"]
    assert_equal(4, times.length)
    p times

    assert_empty times.select { |time| time["start_time"].to_time == "09:00".to_time }
    assert_nil times.select { |time| time["end_time"].to_time == "17:30".to_time }.first

    assert_not_empty times.select { |time| time["start_time"].to_time == "08:40".to_time }
    assert_not_nil times.select { |time| time["end_time"].to_time == "17:10".to_time }.first
    assert_not_empty times.select { |time| time["start_time"].to_time == "09:20".to_time }
    assert_not_nil times.select { |time| time["end_time"].to_time == "17:50".to_time }.first
    assert_not_nil times.select { |time| time["start_time"].to_time == "08:00".to_time }.first
    assert_not_empty times.select { |time| time["end_time"].to_time == "16:30".to_time }
    assert_not_empty times.select { |time| time["start_time"].to_time == "10:00".to_time }
    assert_not_nil times.select { |time| time["end_time"].to_time == "18:30".to_time }.first
  end

  test "Computations - params missing" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)

    @auth_tokens = auth_tokens_for_user(user)

    get "/periods/1/calculations/shift-times",
        params: {
            shift_hours: 8,
            break_minutes: 30,
            per_day: 1
        },
        headers: @auth_tokens
    # todo what should be here?
    assert_response(400)
  end
end
