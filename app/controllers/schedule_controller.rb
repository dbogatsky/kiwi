class ScheduleController < ApplicationController
  before_action :get_api_values,only: [:calendar_event]

  def index
    @users = User.all
  end

  def calendar_event
    @meetings = []
    if params[:users] != "null"
      users = params[:users].split(',')
      apiURL = RequestStore.store[:api_url] + '/conversation_items/search?'
      apiFullUrl = apiURL +  "user_ids=1";
      headers = {}
      headers["Authorization"] = "Token token=\"#{@token}\",email=\"#{@email}\", app_key=\"#{@appKey}\""
      events = HTTParty.get(apiFullUrl,headers: headers)
  	  if events.present?
        events.each do |citem|
    	  	@meetings << citem if citem.type ==  'meeting' || (citem.type == 'note' && citem.scheduled_at.present?)
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
