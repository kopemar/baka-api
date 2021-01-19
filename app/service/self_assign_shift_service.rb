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
    template = ShiftTemplate.where(id: @params[:template_id]).first
    unless template.nil? || contract.nil?
      if template.can_be_assigned?
        shift = Shift.from_template(template)
        shift.schedule_id = contract.schedule_id
        shift.user_scheduled = true
        if shift.save!
          return shift
        end
      end
    end
    nil
  end
end
