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

	def check_in(citem, info)
		if citem.check_ins.present?
      citem.check_ins.each do |ci|
		  ci = info.present? ? OpenStruct.new(ci) : ci
        if ci['user_id'].to_i == current_user.id
          check_in = false
          break
        else
          check_in = true
        end
      end
    else
      check_in = true
    end
    return check_in
	end

	def check_out(citem, info)
		if citem.check_outs.present?
      citem.check_outs.each do |co|
      	co = info.present? ? OpenStruct.new(co) : co
        if co['user_id'].to_i == current_user.id
          check_out = false
          break
        else
          check_out = true
        end
      end
    else
      check_out = true
    end
    return check_out
	end
end
