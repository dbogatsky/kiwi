class ScheduleController < ApplicationController
  before_action :get_api_values,only: [:calendar_event]

  def index
    @users = User.all(reload: true)
    apiURL = RequestStore.store[:api_url] + '/conversation_items/search?'
    apiURL += "user_ids[]=#{current_user.id}"
    headers = {}
    headers["Authorization"] = "Token token=\"#{session[:token]}\",email=\"#{current_user.email}\", app_key=\"#{APP_CONFIG['api_app_key']}\""
    events = HTTParty.get(apiURL,headers: headers)
    @meetings = []

    if events['conversation_items/meetings'].present?
      events['conversation_items/meetings'].each do |citem|
        c_item = OpenStruct.new(citem)
        # Time.zone = current_user.time_zone
        # Chronic.time_class = Time.zone
        if c_item.starts_at.present?
          # c_item_starts_at = Chronic.parse(c_item.starts_at).strftime('%d-%m-%Y')
          today = Chronic.parse(Date.current).strftime('%d-%m-%Y')
          # if c_item_starts_at == today
            @meetings << c_item if c_item.type ==  'meeting'
          # end
        end
      end
    end
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


  private

  def get_api_values
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
