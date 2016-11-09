module ApplicationHelper

	def get_styled_meetingstatus(citem, pulled_right=true)
		pulled_right_class= "pull-right"

		if pulled_right == false
			pulled_right_class = ""
		end
		if citem.status == "scheduled" or citem.status == "canceled" or citem.status == "completed" or citem.status == 'in_progress'
			color = get_meetingstatus_color(citem.status)
			html = "<span class='badge width-68 citem_#{citem.id} " + pulled_right_class + "' style='margin-top: -3px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{citem.status}</span>"
		else citem.status.nil?
			html = "<span class='badge citem_#{citem.id}" + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>Unknown</span>"
		end
		html.html_safe
	end

  # def get_styled_regularmeetingstatus(citem, pulled_right=true)
  #   pulled_right_class= "pull-right"
  #   if pulled_right == false
  #     pulled_right_class = ""
  #   end
  #   statusColor = Hash["scheduled" => "#428BCA", "in progress" => "#ff944d", "completed" => "#4CAF50"]
  #   color = statusColor["completed"]
  #   status = "completed"
  #   if check_in(citem,nil)
  #      color = statusColor["scheduled"]
  #      status = "scheduled"
  #   end
  #   if !check_in(citem,nil) && check_out(citem,nil)
  #       color = statusColor["in progress"]
  #       status = "in progress"
  #   end
  #   html = "<span class='badge width-68 citem_#{citem.id}" + pulled_right_class + "' style='margin-top: -3px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{status}</span>"
  #   html.html_safe
  # end

  def get_styled_quotestatus(citem, pulled_right=true)
    pulled_right_class= "pull-right"

    if pulled_right == false
      pulled_right_class = ""
    end
    if citem.status == "open" or citem.status == "accepted" or citem.status == "rejected" or citem.status == "closed"
      color = get_quotestatus_color(citem.status)
      html = "<span class='badge " + pulled_right_class + "' style='margin-top: 0px; background-color: white; color: #{color}; border: 1px solid #{color};'>#{citem.status}</span>"
    else citem.status.nil?
      html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>Unknown</span>"
    end
    html.html_safe
  end

	def get_meetingstatus_color(meeting_status)
		statusColor = Hash["scheduled" => "#428BCA", "canceled" => "#999", "completed" => "#4CAF50", "in_progress" => "#FF0000"]
		statusColor[meeting_status]
	end

  def get_quotestatus_color(meeting_status)
    statusColor = Hash["open" => "#428BCA", "rejected" => "#999", "accepted" => "#4CAF50", "closed" => "#cc5252"]
    statusColor[meeting_status]
  end

  def check_in(citem, info)
    if citem.check_ins.present?
      citem.check_ins.each do |ci|
        if info.present? || ci.class.name == "Hash"
          ci = OpenStruct.new(ci)
        end
        if ci.user_id.to_i == current_user.id
          @check_in = false
          break
        else
          @check_in = true
        end
      end
    else
      @check_in = true
    end
    return @check_in
	end

	def check_out(citem, info)
		if citem.check_outs.present?
      citem.check_outs.each do |co|
        if info.present? || co.class.name == "Hash"
          co = OpenStruct.new(co)
        end
        if co.user_id.to_i == current_user.id
          @check_out = false
          break
        else
          @check_out = true
        end
      end
    else
      @check_out = true
    end
    return @check_out
	end

  def mobile?
    request_device?(:iphone) || request_device?(:android) || request_device?(:ipad)
  end

  def notifiable_users_json(account)
    users_list = []
    notifiable_users = NotifiableUsers.all(uid: session[:user_id], params: { account_id: account})
    notifiable_users.each do |user|
      users_list << { id: user.id, text: user.first_name + ' ' + user.last_name }
    end
    users_list.to_json
  end

  def check_in_details(citem, info)
    check_in_time = nil
    if citem.check_ins.present?
      citem.check_ins.each do |ci|
        ci = (info.present? || (ci.class.name == "Hash")) ? OpenStruct.new(ci) : ci
        current_user_roles = current_user.roles.collect { |r| r.name }
        if ci.user_id.to_i == current_user.id || current_user_roles.include?('Entity Admin') || current_user_roles.include?('Admin')
          check_in_time = ci.created_at.to_datetime.in_time_zone(current_user.time_zone).strftime("%a %b %d %Y at %l:%M %p")
          break
        end
      end
    end
    return check_in_time
  end

  def check_out_details(citem, info)
    check_out_time = nil
    if citem.check_outs.present?
      citem.check_outs.each do |co|
        co = (info.present? || (co.class.name == "Hash")) ? OpenStruct.new(co) : co
        current_user_roles = current_user.roles.collect { |r| r.name }
        if co.user_id.to_i == current_user.id || current_user_roles.include?('Entity Admin') || current_user_roles.include?('Admin')
          check_out_time = co.created_at.to_datetime.in_time_zone(current_user.time_zone).strftime("%a %b %d %Y at %l:%M %p")
          break
        end
      end
    end
    return check_out_time
  end

  def get_current_company_country
    company = Company.find(uid: RequestStore.store[:tenant])
    if company.addresses.present?
      country = company.addresses.last.country
    else
      country = 'US'
    end

    return country
  end


  def get_current_user_country
    if current_user.addresses.present?
      country = current_user.addresses.last.country
    else
      country = 'US'
    end

    return country
  end

end
