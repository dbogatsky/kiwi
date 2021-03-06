class ScheduleController < ApplicationController
  include ApplicationHelper
  before_action :application_settings, only: [:index, :regular_visits]
  before_action :get_api_values, only: [:index, :calendar_event]
  before_action :get_account_display_setting, only: [:index, :get_events, :get_meeting, :regular_visits ]
  skip_before_filter :verify_authenticity_token, only: [:sort_regular_visits]

  def index
    @@new_item_id = nil
    @@account_conversation_id = nil
    @user_selected = User.find(session[:selected_user]['id']) if session[:selected_user].present?
    @selected_user = User.find(params[:user_id]) if params[:user_id].present?
    @user_preference = user_preferences_load
    @users = User.all(uid: session[:user_id])
    @current_time_fullcalendar = Time.now.in_time_zone(current_user.time_zone) # To correctly set fullcalendar's today's date based on the users timezone
    get_meetings([current_user.id])
    # no_of_account = Account.all.total_entries
    # @all_accounts = Account.all(params: {per_page: no_of_account})
    # @all_accounts = @all_accounts.sort_by {|a| a.name.downcase}
    @sort_meeting = []
    @next_meeting = []
    if @meetings.present?
      @meeting_with_date = []
      @meetings.each do |m|
        @meeting_with_date << m if m.starts_at.present?
      end
      if @meeting_with_date.present?
        @sort_meeting = @meeting_with_date.sort_by do |meeting|
          meeting.starts_at.to_datetime.in_time_zone(current_user.time_zone)
        end
        @sort_meeting.each do |meeting|
          meeting_end_time = meeting.ends_at.to_datetime.in_time_zone(current_user.time_zone)
          current_time = Time.now.in_time_zone(current_user.time_zone)
          @next_meeting << meeting if meeting_end_time > current_time
        end
      end
    end
  end

  def get_account_list_by_scrolling
    search = {}
    search[:name_cont] = params[:term]
    search[:s] = "name asc"
    params[:page] = 1 if params[:page].blank?
    accounts = Account.all(params: {search: search, per_page: 50, page: params[:page]})
    total_pages = accounts.total_pages
    render json: [accounts, total_pages]
  end

  def calendar_event
    if params[:users].present?
      user_ids = [params[:users]]
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

  def get_notifiable_users
    if params[:account_id].present?
      begin
        @notifiable_users = notifiable_users_json(params[:account_id])
        @result = true
      rescue
        @result = false
      end
    end
  end

  def sort_regular_visits
    params[:order].values.each do |order|
      conversation = ConversationItem.find(order['id'], params: { conversation_id: order['conversation_id']})
      conversation_item = {}
      conversation_item[:sort] = order['position']
      conversation.update_attributes(conversation_item: conversation_item, conversation_id: order['conversation_id'], reload: true)
    end
    render :nothing => true
  end

  def get_account_address
    if params[:account_id].present?
      @account =  Account.find(params[:account_id])
      address =  @account.addresses.first
      if address.present?
        @full_address = "#{address.suite_number}" +"#{address.suite_number.present? ? '-' : ''}"+"#{address.street_address}" +', ' + "#{address.city}" +', ' + "#{address.postcode}" +', ' + "#{address.region}" +', ' + "#{address.country}"
      end
    end
  end

  def get_events
    user_ids = []
    if params[:user_id].present?
      user_ids.push(params[:user_id])
    else
      user_ids.push(current_user.id) # push any additional user_id'
    end
    # get the current date
    start_date = params['start']
    end_date = params['end']
    # get all meetings between the date range
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Meeting'
    search[:starts_at_gteq] = "#{start_date} 00:00:00"
    search[:starts_at_lteq] = "#{end_date} 23:59:59"
    search[:item_type_eq] = 'general'

    @meetings = ConversationItemSearch.all(params: { search: search, user_ids: user_ids, per_page: 100 })

    # get reminders where the date is within the date range
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Reminder'
    search[:scheduled_at_gteq] = "#{start_date} 00:00:00"
    search[:scheduled_at_lteq] = "#{end_date} 23:59:59"

    @reminders = ConversationItemSearch.all(params: { search: search, user_ids: user_ids, per_page: 10 })

    # get reminders where the date is within the date range
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Quote'
    search[:ends_at_gteq] = "#{start_date} 00:00:00"
    search[:ends_at_lteq] = "#{end_date} 23:59:59"

    @quotes = ConversationItemSearch.all(params: { search: search, user_ids: user_ids, per_page: 10 })

    events = []
    @meetings.each do |i|
      s_date = Chronic.parse(i.starts_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      e_date = Chronic.parse(i.ends_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      if i.item_type == 'regular'
        all_day = true
        color = '#660066'
      else
        all_day = false
        color = '#3a87ad'
      end

      event_data = {
        account_id: i.account_id,
        id: i.id,
        title: i.title,
        start: s_date,
        end: e_date,
        color: color,
        allDay: all_day,
      }
      events.push(event_data)
    end

    @reminders.each do |i|
      s_date = Chronic.parse(i.scheduled_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      e_date = Chronic.parse(i.scheduled_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      color = '#f0ca45'
      event_data = {
        account_id: i.account_id,
        id: i.id,
        title: i.title,
        start: s_date,
        end: e_date,
        color: color,
        allDay: false,
      }
      events.push(event_data)
    end

    @quotes.each do |i|
      s_date = Chronic.parse(i.ends_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      e_date = Chronic.parse(i.ends_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      color = '#e91e63'
      event_data = {
        account_id: i.account_id,
        id: i.id,
        title: i.title,
        start: s_date,
        end: e_date,
        color: color,
        allDay: true,
      }
      events.push(event_data)
    end

    render json: events
  end

  def regular_visits
    if params[:date].present?
      @date = Chronic.parse(params[:date]).strftime('%Y-%m-%d')
      @formatted_date = Chronic.parse(params[:date]).strftime('%A %B %d, %Y')
      # @date = params[:date]
    else
      @date = Time.now.in_time_zone(current_user.time_zone).strftime('%Y-%m-%d') # To correctly set fullcalendar's today's date based on the users timezone
      @formatted_date = Time.now.in_time_zone(current_user.time_zone).strftime('%A %B %d, %Y')
    end

    user_ids = []
    (['Admin', 'Entity Admin'].include?(current_user.roles.first.name) && params[:user_id].present?) && params[:user_id] != "undefined" ? user_ids.push(params[:user_id]) : user_ids.push(current_user.id)
    @created_by = current_user.id

    # get all meetings between the date range
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Meeting'
    search[:starts_at_gteq] = convert_datetime_to_utc(current_user.time_zone, @date, '00:00:00')
    search[:starts_at_lteq] = convert_datetime_to_utc(current_user.time_zone, @date, '23:59:59')
    search[:item_type_eq] = 'regular'
    search[:s] = "sort asc"
    events = []
    @regular_visits = ConversationItemSearch.all(params: { search: search, user_ids: user_ids, per_page: 50 })
    sort_0_visit = []
    sort_visit = []
    @regular_visits.each do |i|
      sort_0_visit << i if i.sort == 0
      sort_visit << i if i.sort != 0
      s_date = Chronic.parse(i.starts_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      e_date = Chronic.parse(i.ends_at).in_time_zone(current_user.time_zone).strftime('%Y-%m-%dT%H:%M:%S')
      all_day = true
      color = '#660066'

      event_data = {
        account_id: i.account_id,
        id: i.id,
        title: i.title,
        start: s_date,
        end: e_date,
        color: color,
        allDay: all_day,
      }
      events.push(event_data)
    end
    @sorted_regular_visits_count = sort_visit + sort_0_visit
    @sorted_regular_visits= @sorted_regular_visits_count.nil? ? {} : @sorted_regular_visits_count
    render template: 'schedule/_regular_visits', layout: false
  end

  # def search_account
  #   search = {}
  #   search[:name_cont] = params[:str]
  #   options  = []
  #   accounts = Account.all(params: { search: search})
  #   accounts.each do |account|
  #     options << { id: account.id, text: account.name }
  #   end
  #   render json: options
  # end

  private

  def get_meetings(user_ids)
    @all_items = []
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Meeting'
    search[:item_type_eq] = 'general'
    @meetings = ConversationItemSearch.all(params: { search: search, user_ids: user_ids})
    @all_items << @meetings
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Reminder'
    @reminders = ConversationItemSearch.all(params: { search: search, user_ids: user_ids})
    @all_items << @reminders
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Quote'
    @quotes = ConversationItemSearch.all(params: { search: search, user_ids: user_ids})
    @all_items << @quotes
    @all_items = @all_items.flatten
  end

  def get_api_values
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
