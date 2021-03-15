require 'test_helper'

class SchedulingPeriodControllerTest < ActionDispatch::IntegrationTest

  def generate_scheduling_period(org)
    FactoryBot.create(:scheduling_period, organization: org)
  end

  def generate_shift_templates(period, auth_tokens)
    post "/periods/#{period.id}/shift-templates",
         params: {
             working_days: [1, 2, 3, 4, 5],
             start_time: "08:00",
             end_time: "16:30",
             shift_hours: 8,
             break_minutes: 30,
             per_day: 1
         },
         headers: auth_tokens
  end

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

  # todo stack overflow credit
  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'username' and 'password'.
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

    assert_equal([1, 2, 3, 4], times.map { |time| time["id"] })

    start_08_00 = times.select { |time| time["start_time"].to_time == "08:00".to_time }.first
    end_17_10 = times.select { |time| time["end_time"].to_time == "17:10".to_time }.first

    assert_not_nil start_08_00
    assert_equal(1, start_08_00["id"])
    assert_not_empty times.select { |time| time["end_time"].to_time == "16:30".to_time }

    assert_not_nil end_17_10
    assert_equal(2, end_17_10["id"])

    assert_not_empty times.select { |time| time["start_time"].to_time == "08:40".to_time }
    assert_not_empty times.select { |time| time["start_time"].to_time == "09:20".to_time }
    assert_not_nil times.select { |time| time["end_time"].to_time == "17:50".to_time }.first
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

  test "Scheduling templates gen" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)

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

    response_body = response.parsed_body
    assert_response(201)

    assert response_body["templates"].all? { |shift| shift["is_employment_contract"] }

    assert response_body["templates"].length == 20

    Time.zone = "London"
    assert_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 8.hours.after(5.days.after(Time.zone.now.monday)).to_time}
    assert_not_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 8.hours.after(Time.zone.now.monday).to_time}
    assert_not_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 10.hours.after(2.days.after(Time.zone.now.monday)).to_time}
    assert_not_empty response_body["templates"].select{ |shift| shift["end_time"].to_time == 18.hours.after(2.days.after(30.minutes.after(Time.zone.now.monday))).to_time}
    assert_not_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 8.hours.after(40.minutes.after(4.days.after(Time.zone.now.monday))).to_time}
  end

  test "Scheduling templates gen - exclude" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)

    period = FactoryBot.create(:scheduling_period, organization: org)

    post "/periods/#{period.id}/shift-templates",
         params: {
             working_days: [1, 2, 3, 4, 5],
             start_time: "08:00",
             end_time: "18:30",
             shift_hours: 8,
             break_minutes: 30,
             per_day: 4,
             excluded: {
                 1 => [1],
                 2 => [4]
             }
         },
         headers: @auth_tokens

    response_body = response.parsed_body
    assert_response(201)


    # assert response_body["templates"].length == 18
    #
    # assert response_body["templates"].all? { |shift| shift["is_employment_contract"] }
    #
    # Time.zone = "London"
    # assert_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 8.hours.after(5.days.after(Time.zone.now.monday)).to_time}
    # assert_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 8.hours.after(Time.zone.now.monday).to_time}
    # assert_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 10.hours.after(1.days.after(Time.zone.now.monday)).to_time}
    # assert_not_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 10.hours.after(2.days.after(Time.zone.now.monday)).to_time}
    # assert_not_empty response_body["templates"].select{ |shift| shift["end_time"].to_time == 18.hours.after(2.days.after(30.minutes.after(Time.zone.now.monday))).to_time}
    # assert_not_empty response_body["templates"].select{ |shift| shift["start_time"].to_time == 8.hours.after(40.minutes.after(4.days.after(Time.zone.now.monday))).to_time}
  end

  test "Scheduling period days" do
    org = generate_organization
    user = FactoryBot.create(:employee, organization: org)
    @auth_tokens = auth_tokens_for_user(user)

    period = FactoryBot.create(:scheduling_period, organization: org)

    get "/periods/#{period.id}/calculations/period-days",
        headers: @auth_tokens

    parsed_response = response.parsed_body
    tagged_logger.debug parsed_response

    assert parsed_response["days"].length == 7

    assert_empty parsed_response["days"].select { |d| d["id"] == 0 }
    assert_not_empty parsed_response["days"].select { |d| d["id"] == 7 }
    assert_not_empty parsed_response["days"].select { |d| d["date"] == DateTime::now.monday.to_date.to_s }

    assert_not_empty parsed_response["days"].select { |d| d["date"] == 2.days.after(DateTime::now.monday).to_date.to_s }
  end


  test "Generate schedule" do
    org = generate_organization
    user = FactoryBot.create(:manager, organization: org)
    @auth_tokens = auth_tokens_for_user(user)

    period = FactoryBot.create(:scheduling_period, organization: org)

    employee = employee_active_contract(org)

    assert_empty Shift::in_scheduling_period period.id

    generate_shift_templates(period, @auth_tokens)

    post "/periods/#{period.id}/calculations/generate-schedule",
         headers: @auth_tokens
    assert_response(:success)

    templates = ShiftTemplate::in_scheduling_period period.id

    assert_not_empty Shift::in_scheduling_period period.id

    # assert that any random shift was assigned to this ONLY employee
    shifts = employee.contracts.first.schedule.shifts
    Rails.logger.debug "🤫 #{shifts.map(&:shift_template_id)}"
    assert_equal 5, shifts.length

    assert templates.length == shifts.length
  end
end
