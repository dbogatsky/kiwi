module ApplicationHelper

	def get_styled_meetingstatus(citem, pulled_right=true)
		pulled_right_class= "pull-right"

		if pulled_right == false
			pulled_right_class = ""
		end
		if citem.status == "scheduled" or citem.status == "canceled" or citem.status == "completed"
			color = get_meetingstatus_color(citem.status)
			html = "<span class='badge width-68 " + pulled_right_class + "' style='margin-top: -3px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{citem.status}</span>"
		else citem.status.nil?
			html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>Unknown</span>"
		end
		html.html_safe
	end

  def get_styled_quotestatus(citem, pulled_right=true)
    pulled_right_class= "pull-right"

    if pulled_right == false
      pulled_right_class = ""
    end
    if citem.status == "open" or citem.status == "accepted" or citem.status == "rejected" or citem.status == "closed"
      color = get_quotestatus_color(citem.status)
      html = "<span class='badge " + pulled_right_class + "' style='margin-top: -3px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{citem.status}</span>"
    else citem.status.nil?
      html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>Unknown</span>"
    end
    html.html_safe
  end

	def get_meetingstatus_color(meeting_status)
		statusColor = Hash["scheduled" => "#428BCA", "canceled" => "#999", "completed" => "#4CAF50"]
		statusColor[meeting_status]
	end

  def get_quotestatus_color(meeting_status)
    statusColor = Hash["open" => "#428BCA", "rejected" => "#999", "accepted" => "#4CAF50", "closed" => "#cc5252"]
    statusColor[meeting_status]
  end

  def check_in(citem, info)
    if citem.check_ins.present?
      citem.check_ins.each do |ci|
        ci = info.present? ? OpenStruct.new(ci) : ci
        # unless ci.class.name == 'ConversationItem::CheckIn'
        if info.present? || ci.class.name == "Hash"
          ci = OpenStruct.new(ci)
        end
        if ci.user_id.to_i == current_user.id
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
        # unless co.class.name == 'ConversationItem::CheckOut'
        if info.present? || co.class.name == "Hash"
          co = OpenStruct.new(co)
        end
        if co.user_id.to_i == current_user.id
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
