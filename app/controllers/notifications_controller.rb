class NotificationsController < ApplicationController

	def index
		@notifications = Notification.find(:all)
		user_ids = Array.new
	  user_ids.push(current_user.id)
	  @items = []
	  if @notifications.present?
		  @notifications.each do |n|
			  search = {}
		    r = n.value.reminder_id.present? rescue false
		    m = n.value.meeting_id.present? rescue false
		    if r
		      search[:id_eq] = n.value.reminder_id
		    elsif m
		      search[:id_eq] = n.value.meeting_id
		    end
		    ci= ConversationItemSearch.all(params: { user_ids: user_ids, search: search })
		    @items << ci.last
		    search[:id_eq] = nil
		  end
		end
	end
end
