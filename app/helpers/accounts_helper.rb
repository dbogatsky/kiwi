module AccountsHelper
  def get_styled_status(account, pulled_right=true)
    pulled_right_class = 'pull-right'
    pulled_right_class = '' if pulled_right == false

    if account.status.nil?
      html = "<span class='badge " + pulled_right_class + "' style='background-color: #ff860b; border-color: #ff860b;'>No Status</span>"
    else
      html = "<span class='badge " + pulled_right_class + "' style='background-color: #{account.status.color}; border-color: #{account.status.color};'>#{account.status.name}</span>"
    end
    html.html_safe
  end

  def notified_users_options(conversation_item)
    html = ''
    notify_users_list = []

    unless conversation_item.nil?
      conversation_item.conversation_item_user_to_notify.each do |notify_user|
        notify_users_list.push(notify_user.user_id)
      end
    end

    notifiable_users = NotifiableUsers.all(uid: session[:user_id], params: { account_id: conversation_item.account_id })
    notifiable_users.each do |notifiable_user|
      html += "<option value=\"#{notifiable_user.id}\"#{' selected="selected"' if notify_users_list.include?(notifiable_user.id)}>"
      html += "#{notifiable_user.first_name} #{notifiable_user.last_name}</option>\n"
    end

    html.html_safe
  end

  def notified_users(conversation_item)
    html = ''
    notifiable_users_list = {}

    notifiable_users = NotifiableUsers.all(uid: session[:user_id], params: { account_id: conversation_item.account_id })
    notifiable_users.each do |notifiable_user|
      notifiable_users_list[notifiable_user.id] = "#{notifiable_user.first_name} #{notifiable_user.last_name}"
    end

    conversation_item.conversation_item_user_to_notify.each do |notify_user|
      if notifiable_users_list.key?(notify_user.user_id)
        html += '<i class="fa fa-users tooltips mr10" data-toggle="tooltip" data-original-title="Notify to"></i>'
        html += notifiable_users_list[notify_user.user_id]
        html += '<br />'
      end
    end

    html.html_safe
  end

  def advance_search_criteria
    html = ''
    if params[:rule].present?
      params[:rule].values.each do |rule|
        if rule['option'] != "status"
          html += "<span class='search_criteria'>#{rule['option'].capitalize!}: #{rule['text']}</span>"
        else
          html += "<span class='search_criteria'>#{rule['option'].capitalize!}: #{rule['status']}</span>"
        end
      end
    end
    html.html_safe
  end

  def admin_enti_acct_access(account_user_id)
    if current_user.roles.first.name == "Entity Admin" && account_user_id.present?
      @users = User.all(uid: session[:user_id])
      @users.map(&:id).include? account_user_id
    else
      false
    end
  end

end
