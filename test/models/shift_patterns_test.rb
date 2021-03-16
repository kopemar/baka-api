require 'test_helper'

class ShiftPatternsTest < ActiveSupport::TestCase

  # todo move to utils
  def shift_difference_hours(first, other)
    (other.start_time - first.end_time).to_d / 1.hour
  end

  test "Shift Pattern init" do
    o = generate_organization
    periods = FactoryBot.create_list(:scheduling_period, 2, organization_id: o.id).each do |p|
      p.generate_scheduling_units
    end

    templates = FactoryBot.create_list(:shift_template, 3, { organization_id: o.id })
    patterns = Scheduling::ShiftPatterns.new(templates)

    # assert_empty patterns
    Rails.logger.debug "♻️ PATTERNS OF PARAMS 2_4 start"
    patterns_of_2_4 = patterns.patterns_of_params({ length: 2, count: 4 } )
    assert_not_empty patterns_of_2_4
    assert patterns_of_2_4.length == 4
  end

  test "Shift Pattern break enough" do
    o = generate_organization
    p = FactoryBot.create(:scheduling_period, organization_id: o.id)
    p.generate_scheduling_units

    templates = FactoryBot.create_list(:shift_template, 3, :sequence_24_h, { organization_id: o.id })
    patterns = Scheduling::ShiftPatterns.new(templates)

    assert_empty patterns.patterns_of_params({ length: 4} )

    patterns_of_2 = patterns.patterns_of_params({ length: 2 } )
    assert_not_empty patterns_of_2

    Rails.logger.info "🐙 #{patterns_of_2}"
    assert templates.map(&:id).combination(2).to_a.include?(patterns_of_2.first)

    patterns_of_3 = patterns.patterns_of_params({ length: 3 } )
    assert_not_empty patterns_of_3

    Rails.logger.debug "patterns of 3: #{patterns_of_3}"
    assert templates.map(&:id) == patterns_of_3.first
    p patterns_of_3

    patterns_of_2_4 = patterns.patterns_of_params({ length: 2, count: 4 } )
    assert_not_empty patterns_of_2_4
    assert patterns_of_2_4.length == 4
  end

  test "Shift Pattern contains EASY" do
    o = generate_organization

    periods = FactoryBot.create_list(:scheduling_period, 2, :sequence, { organization_id: o.id }).each do |p|
      p.generate_scheduling_units
    end


    templates = FactoryBot.create_list(:shift_template, 3, :sequence_24_h, { organization_id: o.id })
    patterns = Scheduling::ShiftPatterns.new(templates)

    assert_empty patterns.patterns_of_params({ length: 4, :contains => [ templates.first.id ] } )

    pattern_exact = patterns.patterns_of_params({ length: 1, :contains => [ templates.first.id ] } )
    assert_not_empty pattern_exact

    p pattern_exact
    assert pattern_exact.first == [templates.first.id]

    sample = templates.first.id
    pattern_exact_2 = patterns.patterns_of_params({ length: 2, :contains => [ sample ] } )
    assert_not_empty pattern_exact_2

    assert pattern_exact_2.first.include?(sample)
    Rails.logger.debug "🦋 Pattern Exact 2 GOT: #{pattern_exact_2.first}}"
    assert templates.map(&:id).combination(2).to_a.filter { |f| f.include?(sample) }.include?(pattern_exact_2.first)

    Rails.logger.info "🐿🐿🐿🐿  PATTERNS EXACT 2:2   🐿🐿🐿🐿 "
    pattern_exact_2_2 = patterns.patterns_of_params({ length: 2, :contains => [ templates[0].id, templates[1].id ] } )
    assert_not_empty pattern_exact_2_2
    assert pattern_exact_2_2.first == [ templates[0].id, templates[1].id ]

    pattern_exact_3 = patterns.patterns_of_params({ length: 3, :contains => [ templates.sample.id ] } )
    Rails.logger.debug "🦋 Pattern Exact 3 GOT: #{pattern_exact_3.first}, EXPECTED: #{templates.map(&:id)}"
    assert pattern_exact_3.first == templates.map(&:id)

  end

  test "Shift Patterns – period 3 : 5" do
    o = generate_organization
    p = FactoryBot.create(:scheduling_period, organization_id: o.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id=> p.id,
            :working_days => [1, 2, 3, 4, 5],
            :start_time => "08:00",
            :end_time => "21:00",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 3
        }
    )

    patterns = Scheduling::ShiftPatterns.new(templates)

    assert templates.length == 15

    # Rails.logger.debug "😍 #{templates}"

    first = templates.sample
    second = templates.find { |s| shift_difference_hours(first, s) > MINIMUM_BREAK_HOURS }

    third = templates.find { |s| shift_difference_hours(first, s) > MINIMUM_BREAK_HOURS && shift_difference_hours(second, s) > MINIMUM_BREAK_HOURS }

    if second.nil?
      second = templates.find { |s| shift_difference_hours(s, first) > MINIMUM_BREAK_HOURS }
      third = templates.find { |s| shift_difference_hours(first, s) > MINIMUM_BREAK_HOURS && shift_difference_hours(s, second) > MINIMUM_BREAK_HOURS }
    end

    if third.nil?
      third = templates.find { |s| shift_difference_hours(first, s) > MINIMUM_BREAK_HOURS && shift_difference_hours(second, s) > MINIMUM_BREAK_HOURS } ||
          templates.find { |s| shift_difference_hours(s, first) > MINIMUM_BREAK_HOURS && shift_difference_hours(s, second) > MINIMUM_BREAK_HOURS } ||
          templates.find { |s| shift_difference_hours(first, s) > MINIMUM_BREAK_HOURS && shift_difference_hours(s, second) > MINIMUM_BREAK_HOURS } ||
          templates.find { |s| shift_difference_hours(s, first) > MINIMUM_BREAK_HOURS && shift_difference_hours(second, s) > MINIMUM_BREAK_HOURS }
    end

    contains_2 = [first, second].map(&:id)
    contains_3 = contains_2.clone.push(third.id)

    patterns_of_2 = patterns.patterns_of_params({ length: 2, contains: contains_2 } )
    Rails.logger.debug "🤪 patterns_of_2: #{patterns_of_2}, contains: #{contains_2}"

    assert_not_empty patterns_of_2
    assert_equal 2, patterns_of_2.first.length
    assert patterns_of_2.first.to_set == contains_2.to_set

    patterns_of_3 = patterns.patterns_of_params({ length: 3, contains: contains_2 } )
    Rails.logger.debug "🤪 patterns_of_3: #{patterns_of_3}"
    assert_not_nil patterns_of_3.first
    assert_equal 3, patterns_of_3.first.length

    patterns_of_4 = patterns.patterns_of_params({ length: 4, contains: contains_2 } )
    Rails.logger.debug "🤪 patterns_of_4: #{patterns_of_4}"
    assert_not_empty patterns_of_4
    assert_equal 4, patterns_of_4.first.length
    assert patterns_of_4.first.to_set.superset?(contains_2.to_set)

    patterns_of_5 = patterns.patterns_of_params({ length: 5, contains: contains_2 } )
    Rails.logger.debug "🤪 patterns_of_5: #{patterns_of_5}"
    assert_not_empty patterns_of_5
    assert_equal 5, patterns_of_5.first.length
    assert patterns_of_5.first.to_set.superset?(contains_2.to_set)

    patterns_of_3_3 = patterns.patterns_of_params({ length: 3, contains: contains_3 } )
    Rails.logger.debug "🤪 patterns_of_3: #{patterns_of_3_3}"
    assert_not_nil patterns_of_3_3.first
    assert_equal 3, patterns_of_3_3.first.length
    assert patterns_of_3_3.first.to_set.subset? contains_3.to_set

  end

end