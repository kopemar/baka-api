class SelfAssignShiftService < ApplicationService

  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def call
    if @params[:schedule_id].nil? || @params[:template_id].nil?
      return
    end
    contract = Contract::active_agreements.where(employee_id: @current_user.id).where(schedule_id: @params[:schedule_id]).first
    template = ShiftTemplate.find(@params[:template_id].to_i)
    unless template.nil? || contract.nil?
      if template.can_be_user_assigned?(contract)
        shift = Shift.from_template(template)
        shift.schedule_id = contract.schedule_id
        shift.user_scheduled = true
        shift.scheduler_type = SCHEDULER_TYPES[:EMPLOYEE]
        if shift.save!
          return shift
        end
      end
    end
    nil
  end
end
