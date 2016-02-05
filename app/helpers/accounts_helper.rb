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
end
