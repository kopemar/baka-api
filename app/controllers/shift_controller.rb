class ShiftController < ApplicationController
  before_action :authenticate_user!

  def get_user_schedule
    schedule = if params[:start_date].nil? && params[:end_date].nil?
                 Shift.all.order(:start_time)
                 UserScheduleService.call(current_user).order(:start_time)
               elsif params[:start_date].nil?
                 UserScheduleService.call(current_user, nil, params[:end_date].to_date).order('shifts.start_time DESC')
               elsif params[:end_date].nil?
                 UserScheduleService.call(current_user, params[:start_date].to_date, nil).order('start_time')
               else
                 UserScheduleService.call(current_user, params[:start_date].to_date, params[:end_date].to_date).order(:start_time)
               end

    render json: {
        :shifts => @collection = schedule.paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
        :current_page => @collection.current_page,
        :total_pages => @collection.total_pages,
        :has_next => @collection.next_page.present?
    }
  end
end
