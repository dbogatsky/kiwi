class ScheduleController < ApplicationController

  def index
    @users = User.all
  end

  def calendar_event
  	if params[:users].present?
  	users = params[:users].split(',')
    @events = ConversationItem.find(:all,params: {conversation_id: 61,users_id: users})
  	end
  end
end
