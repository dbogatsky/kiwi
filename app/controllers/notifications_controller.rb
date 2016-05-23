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
		binding.pry
	end
end
