module AccountsHelper
	def get_styled_status(account, pulled_right=true)
		pulled_right_class= "pull-right"
		if pulled_right == false
			pulled_right_class = ""
		end
		if account.status.nil?
			html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>No Status</span>"
		else
			html = "<span class='badge " + pulled_right_class + "' style='background-color: #{account.status.color}; border-color: #{account.status.color};'>#{account.status.name}</span>"
		end
		html.html_safe
	end


	def get_styled_meetingstatus(citem, pulled_right=true)
		pulled_right_class= "pull-right"
		
		# status colors
		statusColor = Hash["scheduled" => "#428BCA", "cancelled" => "#999", "compelted" => "#1CC7C2"]

		if pulled_right == false
			pulled_right_class = ""
		end

		if citem.status = "scheduled" or citem.stauts = "cancelled" or citem.stauts = "completed"
			color = statusColor[citem.status]
			html = "<span class='badge " + pulled_right_class + "' style='margin-top: -3px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{citem.status}</span>"
		else citem.status.nil?
			html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>Unknown</span>"
		end
		html.html_safe
	end




end
