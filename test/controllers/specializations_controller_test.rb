require 'test_helper'

class SpecializationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @org = generate_organization
    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)
  end

  test "Specialization create test" do
    # Signed in as manager. Adds new specialization.
    m1_tokens = @auth_tokens
    n1 = "Clown"
    post "/specializations", params: {name: n1}, headers: m1_tokens
    assert_response 201

    # Sign in as another user.
    org = Organization.create!(name: "Testers Inc.")
    user = FactoryBot.create(:manager, organization: org)
    m2_tokens = auth_tokens_for_user(user)

    # Add another specialization
    n2 = "Cook"
    post "/specializations", params: {name: n2}, headers: m2_tokens
    assert_response 201

    get "/specializations", headers: @auth_tokens
    assert_response :success

    m1_response = response.parsed_body.deep_symbolize_keys[:data]
    assert_equal 1, m1_response.length

    assert_not_nil m1_response.filter { |item| item[:name] == n1 }.first
    assert_nil m1_response.filter { |item| item[:name] == n2 }.first

    get "/specializations", headers: m2_tokens
    assert_response :success

    m2_response = response.parsed_body.deep_symbolize_keys[:data]
    assert_equal 1, m2_response.length

    assert_not_nil m2_response.filter { |item| item[:name] == n2 }.first
    assert_nil m2_response.filter { |item| item[:name] == n1 }.first

    assert_equal 2, Specialization.count
  end

  test "Get Employees for specialization" do
    m1_tokens = @auth_tokens

    n1 = "Clown"
    post "/specializations", params: {name: n1}, headers: m1_tokens

    get "/specializations", headers: m1_tokens

    m1_specialization_id = response.parsed_body.deep_symbolize_keys[:data].first[:id]

    e1 = employee_active_contract(@org)
    e2 = employee_active_contract(@org)

    contracts = Contract.where(employee_id: [e1.id]).to_a
    patch "/specializations/#{m1_specialization_id}", params: {employees: contracts.map(&:id)}, headers: m1_tokens

    get "/specializations/#{m1_specialization_id}/calculations/contracts", headers: m1_tokens
    Rails.logger.debug response.parsed_body.deep_symbolize_keys

    assert_not_empty response.parsed_body.deep_symbolize_keys[:data]

    e1_contract = Contract.where(employee_id: [e1.id]).first
    e2_contract = Contract.where(employee_id: [e2.id]).first

    Rails.logger.debug "⛑ #{e2_contract.specializations}"

    assert_empty response.parsed_body.deep_symbolize_keys[:data].filter { |item| item[:id] == e1_contract.id }
    assert_not_empty response.parsed_body.deep_symbolize_keys[:data].filter { |item| item[:id] == e2_contract.id }
  end

end
