module ApplicationHelper
	def get_styled_meetingstatus(citem, pulled_right=true)
		pulled_right_class= "pull-right"

		# status colors
		statusColor = Hash["scheduled" => "#428BCA", "canceled" => "#999", "completed" => "#4CAF50"]

		if pulled_right == false
			pulled_right_class = ""
		end
		if citem.status == "scheduled" or citem.status == "canceled" or citem.status == "completed"
			color = statusColor[citem.status]
			html = "<span class='badge " + pulled_right_class + "' style='margin-top: -3px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{citem.status}</span>"
		else citem.status.nil?
			html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>Unknown</span>"
		end
		html.html_safe
	end
end
