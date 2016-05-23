class NotificationsController < ApplicationController

	def index
	end

	def update
		begin
		  @notification = Notification.find(params[:id])
	    @notification.update_attributes(read_at: Time.now)
	    notification_info
	    @result = true
	  rescue
	  	@result = false
	  end
	end

	def conversation_detail
		if params[:notification_read] == "false"
		   @notification = Notification.find(params[:notification_id])
		   @notification.update_attributes(read_at: Time.now)
		   notification_info
		end
		@notification_type = params[:notification_type]
		@item = params[:notification_type] == 'account_status_change' ? Account.find(params[:item_id]) : ConversationItem.find(params[:item_id], params: {conversation_id: params[:conversation_id]})
	end
end
