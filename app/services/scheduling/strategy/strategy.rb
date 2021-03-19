module Scheduling
  module Strategy
    class Strategy
      attr_reader :violations, :solution, :patterns, :utilization, :employee_groups, :assigned_employees, :shift_duration

      def initialize(params)
        parse_params(params)
      end

      def self.try_to_improve(params, strategy)
        strategy.new(params).try_to_improve
      end

      def parse_params(params = {})
        @violations = params.fetch(:violations)
        @solution = params.fetch(:solution)
        @patterns = params.fetch(:patterns)
        @utilization = params.fetch(:utilization, nil)
        @employee_groups = params.fetch(:employee_groups, nil)
        @employees = params.fetch(:assigned_employees, nil)
        @shift_duration = params.fetch(:shift_duration, nil)
      end

    end
  end
end
