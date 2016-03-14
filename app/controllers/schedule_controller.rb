class ScheduleController < ApplicationController
  before_action :get_api_values,only: [:index, :calendar_event]


  def index
    @users = User.all(reload: true)
    get_meetings([current_user.id])
    @sort_meeting = []
    @next_meeting = []
    if @meetings.present?
      @sort_meeting =  @meetings.sort_by do |meeting|
          meeting[:starts_at].to_datetime.in_time_zone(current_user.time_zone)
      end
      @sort_meeting.each do |meeting|
         meeting_end_time = meeting.ends_at.to_datetime.in_time_zone(current_user.time_zone)
         meeting_start_time = meeting.ends_at.to_datetime.in_time_zone(current_user.time_zone)
         current_time = Time.now.in_time_zone(current_user.time_zone)
         @next_meeting << meeting if meeting_end_time > current_time
      end
    end
  end

  def calendar_event
    if params[:users].present?
      user_ids = params[:users]
    else
      user_ids = [current_user.id]
    end
    get_meetings(user_ids)
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
    def get_meetings(user_ids)
      @colors = ['#e0301e', '#000', '#c5e323', '#9e466b', '#0000ff']
      @meetings = []
      @user_color = {}
      user_ids.each_with_index do |u, index|
        if u.to_i != current_user.id
           @user_color[u.to_i] = @colors[index]
        else
           @user_color[u.to_i] = "#3a87ad"
        end
      end
      apiURL = RequestStore.store[:api_url] + '/conversation_items/search?'
      user_ids.each do |user_id|
        apiURL += "user_ids[]=#{user_id}&"
      end
      headers = {}
      headers["Authorization"] = "Token token=\"#{@token}\",email=\"#{@email}\", app_key=\"#{@appKey}\""
      events = HTTParty.get(apiURL,headers: headers)

      if events['conversation_items/meetings'].present?
        events['conversation_items/meetings'].each_with_index do |citem, index|
          c_item = OpenStruct.new(citem)
          @meetings << c_item if c_item.type ==  'meeting' || (c_item.type == 'note' && c_item.scheduled_at.present?)
        end
      end
      @meetings
    end

    def get_api_values
      @email = current_user.email
      @appKey = APP_CONFIG['api_app_key']
      @token = session[:token]
    end
end
