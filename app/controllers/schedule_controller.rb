class ScheduleController < ApplicationController

  def index
    @users = User.all
  end

  def calendar_event
  	if params[:users].present?
	  	users = params[:users].split(',')
	    events = ConversationItem.find(:all,params: {conversation_id: 61,users_id: users})
	  	@meetings = []
	  	events.each do |citem|
	  	  @meetings << citem if citem.type.eql? 'meeting'
	  	end
	  end
  end

  def get_meeting
     @meeting = ConversationItem.find(params[:citem_id],params: {conversation_id: 61})
  end
end
