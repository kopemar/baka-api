class SchedulingPeriodController < ApplicationController
  def all
    unless params[:from].nil?
      return render json: {
          :periods => @collection = SchedulingPeriod.where("end_date >= ?", params[:from]).paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
          :current_page => @collection.current_page,
          :total_pages => @collection.total_pages,
          :has_next => @collection.next_page.present?
      }
    end
    render json: {
        :periods => @collection = SchedulingPeriod.all.paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
        :current_page => @collection.current_page,
        :total_pages => @collection.total_pages,
        :has_next => @collection.next_page.present?
    }
  end
end
