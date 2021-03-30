module Scheduling
  module Strategy
    class SpecializedPreferredStrategy < Strategy
      def initialize(params)
        super(params)
      end

      def try_to_improve
        Rails.logger.debug "🐻 violations #{violations}"

        viable_employees = solution.filter { employee_groups.any? { |k, v| !k[:specializations].empty? }
        }.sort_by { |_, v| v.length }

        viable_employees.each do |k, v|
          Rails.logger.debug "🐼 #{v}"
          specializations = employee_groups.filter { |_, value| value.map(&:id).include? k }.keys.first[:specializations]
          patterns.try_to_specialize(v, specializations)
        end

        # Umim zjistit, jaky smeny to porusujou nejvic
        # employee_groups.filter { |k, _| !k[:specializations].empty? }.each do |k, v|
        #   sample = templates.find { |template| template.id == violations.keys.sample }
        #   Rails.logger.debug "🐧 sample #{sample}"
        #   unless sample.nil? || sample.sub_templates.empty?
        #     analyze_combinations(v.map(&:id), k[:specializations], [ sample.id ])
        #   end
        # end
        solution
      end

      private

      def analyze_combinations(employees, specializations, contains)

        patterns = @patterns.patterns_of_params({:length => 5, :contains => contains, :specializations => specializations })

        unless patterns.first.nil? || employees.empty?
          employees.each do |e|
            sample = patterns.sample
            Rails.logger.debug "🙈 EMPLOYEE #{e} to #{sample}"
            solution[e] = sample
          end

          return true
        end
      end
      false
    end
  end
end
