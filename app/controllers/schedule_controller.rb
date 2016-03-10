class ScheduleController < ApplicationController
  before_action :get_api_values,only: [:calendar_event]

  def index
    @users = User.all(reload: true)
  end

  def calendar_event
    @meetings = []
    if params[:users] != "null"
      users = params[:users].split(',')
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
