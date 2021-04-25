module Api
  module V1
    class SchedulingUnitController < ApplicationController
      def in_period
        render :json => {:data => SchedulingUnit.where(scheduling_period_id: params[:id])}
      end
    end
  end
end