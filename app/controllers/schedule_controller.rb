class ScheduleController < ApplicationController
  before_action :get_api_values,only: [:calendar_event]



  def index
    @users = User.all(reload: true)
  end



  def calendar_event
    @meetings = []
    if params[:users] != "null"
      users = params[:users].split(',')
    else
      users = [current_user.id]
    end
    apiURL = RequestStore.store[:api_url] + '/conversation_items/search?'
    users.each do |user_id|
      apiURL += "user_ids[]=#{user_id}&"
    end
    headers = {}
    headers["Authorization"] = "Token token=\"#{@token}\",email=\"#{@email}\", app_key=\"#{@appKey}\""
    events = HTTParty.get(apiURL,headers: headers)
    if events['conversation_items/meetings'].present?
      events['conversation_items/meetings'].each do |citem|
        c_item = OpenStruct.new(citem)
  	  	@meetings << c_item if c_item.type ==  'meeting' || (c_item.type == 'note' && c_item.scheduled_at.present?)
  	  end
	  end
  end



  def get_meeting
    @account = Account.find(params[:account_id])
    c_id = @account.conversation.id
    @meeting = ConversationItem.find(params[:citem_id],params: {conversation_id: c_id})
  end



  def get_events
    user_ids = Array.new
    user_ids.push(current_user.id) #push any additional user_id'

    #get the current date
    start_date = params['start']
    end_date = params['end']

    search = Hash.new
    search[:type_eq]="ConversationItems::Meeting"
    search[:starts_at_gteq]="#{start_date} 00:00:00"
    search[:starts_at_lteq]="#{end_date} 23:59:59"

    @meetings = ConversationItemSearch.all(params: {user_ids: user_ids, search: search})

    events = Array.new
    @meetings.each do |i|
      s_date = Chronic.parse(i.starts_at).in_time_zone(current_user.time_zone).strftime("%Y-%m-%dT%H:%M:%S")
      e_date = Chronic.parse(i.ends_at).in_time_zone(current_user.time_zone).strftime("%Y-%m-%dT%H:%M:%S")
      event_data = {
        account_id: i.account_id,
        id: i.id,
        title: i.title,
        start: s_date,
        end: e_date,
        allDay: false
      }
      events.push(event_data)
    end
    render json: events
  end

  private

  def get_api_values
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
