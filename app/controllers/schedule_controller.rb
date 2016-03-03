class ScheduleController < ApplicationController

  def index
    @users = User.all
  end

  def calendar_event
  	if params[:users].present?
  	events = []
  	users = params[:users].split(',')
  	    users.each do |u|
  	    end
  	end
  end
end
