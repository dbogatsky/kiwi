require 'net/http/post/multipart'
include ApplicationHelper
class AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:delete_future_meeting, :destroy]
  before_action :get_token
  before_action :find_account, only: [:show, :edit, :destroy, :conversation, :search, :add_quote, :edit, :update, :share, :update_note, :update_email, :delete_note, :delete_email, :schedule_meeting, :delete_meeting, :update_meeting, :delete_future_meeting, :update_quote, :delete_quote, :add_reminder, :update_reminder, :delete_reminder]
  before_action :get_api_values, only: [:search]
  before_action :application_settings, only: [:index, :show, :new, :edit, :generate_properties_csv_template, :properties_csv_validates, :assets_csv_validates, :generate_assets_csv_template]
  before_action :get_setting, only: [:index, :import, :export, :show, :edit, :new, :schedule_meeting, :update_meeting, :add_reminder, :update_reminder, :add_quote, :update_quote, :send_email, :update_email ]
  before_action :check_permission_for_import, only: [:import]
  before_action :check_permission_for_export, only: [:export]
  @@account_with_previous_value = nil

  def index
    @user_preference = user_preferences_load
    if (@search_all_accounts == 'enable' && @role != 'Admin')
      if params[:company_search].present?
        session[:company_search] = (params[:company_search] == 'true') ? true : false
      elsif session[:company_search].blank?
        session[:company_search] = false
      end
    end
    show_accounts_per_page = @user_preference['show_accounts_per_page']
    @show_accounts_per_page = show_accounts_per_page.to_i > 0 ? show_accounts_per_page.to_i : 26
    page = params[:page].present? ? params[:page] : 1
    session[:page] = page
    advanced_search  #call advanced search
    if params[:view_all].present?
       session.delete(:search)
       if (@search_all_accounts == 'enable' && @role != 'Admin')
          session[:company_search] = false
       end
    end
    search = @search.present? ? @search : (params[:search].present? ? params[:search] : session[:search])
    if params[:search1].present? && params[:search2].present?
      search ||= {}
      search[:s] = "#{params[:search1][:search]+' '+params[:search2][:search]}"
    end
    search = session[:search] if params[:adv_search] == 'true'

    if (@search_all_accounts == 'enable' && @role != 'Admin')
      @accounts = Account.all(params: { company_search: session[:company_search], search: search, page: page, per_page: @show_accounts_per_page})
    else
      @accounts = Account.all(params: { search: search, page: page, per_page: @show_accounts_per_page})
    end
    @total_entries = @accounts.meta["total_entries"]
    session[:search] = search
    accounts_statistics_info
    respond_to do |format|
      format.html
      if request.format.symbol == :csv
        format.csv { send_data generate_csv }
      elsif request.format.symbol == :xls
        format.xls { send_data generate_csv }
      end
    end

    #checkd = CheckDuplication.all(uid: session[:user_id], params: {name: "Shoppers Drug Mart", addresses: {street_address: "", city: "", postcode: "", region: "", country: "", suite_number: "" }} )
  end

  def show
    # Get the acount info and conversation based on id given
    @shared_user = []
    @account.user_account_sharings.each { |u| @shared_user << u.user }
    @users = User.all(uid: session[:user_id])
    @notifiable_users = notifiable_users_json(params[:id])
    @timeline_conversation_items = @account.conversation.conversation_items
  end

  def new
    # Add an account
    @account = Account.new
    @users = User.all(uid: session[:user_id])
  end

  def edit
    # Edit an account
    @addresses = @account.addresses
    @contacts = @account.contacts
    @users = User.all(uid: session[:user_id])
    @@account_with_previous_value = @account
  end

  def create
    puts "RECEIVED PARAMS = #{account_params}"
    # Create new account
    if params.key?(:save)
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
      params[:account][:properties] = params[:account][:properties].to_json
      @account = Account.new(request: :create, account: account_params)
      if @account.save
        save_avatar
        flash[:success] = 'Account has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the account'
      end
    end
    redirect_to accounts_path
  end

  def update
    # Update account
    if params.key?(:save)
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values if params[:account][:contacts_attributes].present?
      params[:account][:properties] = params[:account][:properties].to_json
      if @account.update_attributes(name: @account.name, account: account_params)
        save_avatar
        conversation_item_body = account_update_info(@@account_with_previous_value, @account)
        c_id = @account.conversation.id
        conversation_item_title ="Account info changed on " + "#{Time.now.in_time_zone(current_user.time_zone).strftime('%a %b %d %Y at %l:%M %p')}"
        ConversationItem.create(conversation_item: { title: conversation_item_title, body: conversation_item_body, created_by_id: current_user.id }, conversation_id: c_id, type: 'account')
        flash[:success] = 'Account has been edited successfully'
      else
        flash[:danger] = 'Oops! Unable to edit the account'
      end
    end
    redirect_to account_path(params[:id])
  end

  def destroy
    if @account.destroy
      flash[:success] = 'Account has been deleted successfully'
    else
      flash[:danger] = 'Oops! Unable to delete the account'
    end
    render :nothing => true
  end


  def load_more_conversation_item
    @account = params[:id]
    @conversation_id = params[:conversation_id]
    @conversation_items =  ConversationItem.find(:all, params: {conversation_id: @conversation_id, page: params[:page]})
    @next_page = @conversation_items.next_page
  end

  def add_asset
    params[:asset][:properties] = params[:asset][:properties].to_json if params[:asset][:properties].present?
    @asset = Asset.new(request: :create, asset: asset_params, account_id: params[:id])
    if @asset.save
      flash[:success] = 'Asset has been added successfully'
    else
      flash[:danger] = 'Oops! Unable to add the asset'
    end
    redirect_to account_path(params[:id])
  end

  def update_asset
    @asset = Asset.find(params['pk'],params: {account_id: params[:account_id]}) rescue nil
    if @asset.present?
      asset = {}
      if params[:name] == 'name'
        asset[:name] = params['value']
      elsif params[:name] == 'description'
        asset[:description] = params['value']
      else
        @asset.properties.attributes[params['name']] = params['value']
        asset[:properties] = @asset.properties.attributes.to_json
      end
      @asset.update_attributes(asset: asset, account_id: params[:account_id])
    end
    render :nothing => true
  end

  def schedule_meeting
    c_id = @account.conversation.id
    if params[:conversation_item][:item_type] == 'regular'
      if params[:conversation_item][:title].blank?
        params[:conversation_item][:title] =  @account.name+' '+ params[:conversation_item][:repetition_rule][:frequency_type].capitalize+' '+'Visits'
      else
        params[:conversation_item][:title]  = params[:conversation_item][:title].titleize
      end
    end
    if params[:conversation_item][:item_type] == 'regular' && params[:starts_date].present?
      params[:conversation_item][:all_day_appointment] = true
      params[:conversation_item][:starts_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], "00:00:00")
      params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], "23:59:59")
      params[:conversation_item][:invitees] = ""
    else
      params[:conversation_item][:starts_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], params[:starts_time]) if params[:starts_date].present?
      params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:ends_date], params[:ends_time]) if params[:ends_date].present?
      params[:conversation_item][:all_day_appointment] = false
    end

    if params[:scheduled_date].present? && params[:scheduled_time].present?
      params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
    else
      params[:conversation_item][:scheduled_at] = nil
      params[:conversation_item][:reminder] = nil
    end
    check_daylight   #call to check daylight
    if params[:conversation_item][:repetition_rule][:frequency_type] == 'monthly'
      params[:conversation_item][:repetition_rule][:day_of_month] = params[:conversation_item][:starts_at].to_datetime.day if params[:month_week] == 'dayofmonth'
      params[:conversation_item][:repetition_rule][:weekday_of_month] = params[:conversation_item][:starts_at].to_datetime.wday if params[:month_week] == 'dayofweek'
      params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_month]
    elsif params[:conversation_item][:repetition_rule][:frequency_type] == 'weekly'
      params[:conversation_item][:repetition_rule][:day_of_week] = params[:conversation_item][:repetition_rule][:day_of_week].map{|x| x.to_i} if params[:conversation_item][:repetition_rule][:day_of_week].present?
      params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_week]
    elsif params[:conversation_item][:repetition_rule][:frequency_type] == 'daily'
      params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_day]
    elsif params[:conversation_item][:repetition_rule][:frequency_type] == 'yearly'
      params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_year]
    end
    ci = ConversationItem.create(
      conversation_item: {
        title:              conversation_item_params[:title],
        body:               conversation_item_params[:body],
        latitude:           params[:conversation_item][:latitude],
        longitude:          params[:conversation_item][:longitude],
        invitees:           params[:conversation_item][:invitees],
        scheduled_at:       params[:conversation_item][:scheduled_at],
        location:           params[:conversation_item][:location],
        reminder:           params[:conversation_item][:reminder],
        starts_at:          params[:conversation_item][:starts_at],
        ends_at:            params[:conversation_item][:ends_at],
        item_type:          params[:conversation_item][:item_type],
        all_day_appointment: params[:conversation_item][:all_day_appointment],
        repetition_rules: {
          frequency_type:     params[:conversation_item][:repetition_rule][:frequency_type],
          frequency:          params[:conversation_item][:repetition_rule][:frequency],
          repeat_occurrences: params[:conversation_item][:repetition_rule][:repeat_occurrences],
          day_of_week:        params[:conversation_item][:repetition_rule][:day_of_week],
          day_of_month:       params[:conversation_item][:repetition_rule][:day_of_month],
          weekday_of_month:   params[:conversation_item][:repetition_rule][:weekday_of_month],
          created_by_id: current_user.id
          },
        },
        conversation_id: c_id, type: 'meeting')
    if ci
      flash[:success] = 'Your meeting has been successfully scheduled'
    else
      flash[:danger] = 'Oops! Unable to scheduled meeting'
    end
    if params[:add_from_schedule].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def delete_meeting
    @conversation = ConversationItem.find(params[:item_id], params: { conversation_id: @account.conversation.id })
    if @conversation.present? && (@conversation.related_to.present? || @conversation.repetition_rule.present?)
      @show_alert = true
    else
      @show_alert = false
    end
    @conversation = @conversation.id
    respond_to do |format|
      format.js { render template: 'accounts/delete_meeting.js.erb' }
    end
  end

  def delete_future_meeting
    @item = ConversationItem.find(params[:citem_id], params: { conversation_id: @account.conversation.id })
    if params[:destroy_future_meetings].present?
      ConversationItem.delete(@item.id, { destroy_future_meetings: true, conversation_id: @account.conversation.id })
      flash[:success] = 'All future Meeting successfully deleted'
    else
      @item.destroy
      flash[:success] = 'Meeting successfully deleted'
    end
    render js: 'window.location.reload()'
  end

  def update_meeting
    conversation_id = @account.conversation.id
    unless params[:conversation_item][:status].present?
      if params[:scheduled_date].present? && params[:scheduled_time].present?
        params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
      else
        params[:conversation_item][:scheduled_at] = nil
        params[:conversation_item][:reminder] = nil
      end
    end
    @conversation = ConversationItem.find(params[:conversation_item][:id], params:{conversation_id: @account.conversation.id})

    if @conversation.item_type == 'regular' && params[:starts_date].present?
      params[:conversation_item][:starts_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], "00:00:00")
      params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], "23:59:59")
    else
      params[:conversation_item][:starts_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], params[:starts_time]) if params[:starts_date].present?
      params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:ends_date], params[:ends_time]) if params[:ends_date].present?
    end
    if @conversation.item_type == 'regular'
      params[:conversation_item][:title]  = params[:conversation_item][:title].present? ? params[:conversation_item][:title].titleize : @conversation.title
    end
    check_daylight #call to check daylight
    if (params[:conversation_item][:status].present?) && (@conversation.check_ins.map(&:user_id).include?current_user.id) && (@conversation.status == 'in_progress')
      lat = request.location.latitude rescue 0.0
      lng = request.location.longitude rescue 0.0
      ip_address = request.location.ip rescue nil
      ConversationItemEvent.create(conversation_item_event: { lat: lat, long: lng, ip_address: ip_address }, type: 'check_out', conversation_item_id: @conversation.id)
    end
    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id, reload: true)
      flash[:success] = 'Meeting successfully updated!'
    else
      flash[:danger] = 'Meeting not updated!'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def check_in
    citem = params['cid']
    lat = 0.0
    lng = 0.0

    if params['lat'].nil? || params['lng'].nil?
      ip_address = request.location.ip
      lat = request.location.latitude
      lng = request.location.longitude
    else
      ip_address = params[:ip_address]
      lat = params['lat']
      lng = params['lng']
    end
    ci = ConversationItemEvent.create(conversation_item_event: { lat: lat, long: lng, ip_address: ip_address }, type: 'check_in', conversation_item_id: citem)
    conversation = ConversationItem.find(params[:cid], params:{conversation_id: params[:conversation_id]})
    if params[:created_by].to_i == current_user.id
      params[:conversation_item] = {}
      params[:conversation_item][:status] = "in_progress"
      conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: params[:conversation_id], reload: true)
    end
    check_in_time = ci.created_at.to_datetime.in_time_zone(current_user.time_zone).strftime("%a %b %d %Y at %l:%M %p")
    ci = ci.present? ? 'check_in' : nil
    status = conversation.status
    render json: [status, ci, check_in_time]
  end

  def check_out
    citem = params['cid']
    lat = 0.0
    lng = 0.0

    if params['lat'].nil? || params['lng'].nil?
      ip_address = request.location.ip
      lat = request.location.latitude
      lng = request.location.longitude
    else
      ip_address = params[:ip_address]
      lat = params['lat']
      lng = params['lng']
    end
    co = ConversationItemEvent.create(conversation_item_event: { lat: lat, long: lng, ip_address: ip_address }, type: 'check_out', conversation_item_id: citem)
    conversation = ConversationItem.find(params[:cid], params:{conversation_id: params[:conversation_id]})
    if params[:created_by].to_i == current_user.id
      params[:conversation_item] = {}
      params[:conversation_item][:status] = "completed"
      conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: params[:conversation_id], reload: true)
    end
    check_out_time = co.created_at.to_datetime.in_time_zone(current_user.time_zone).strftime("%a %b %d %Y at %l:%M %p")
    status = conversation.status
    co = co.present? ? 'check_out' : nil
    render json: [status, co, check_out_time]
  end

  def jump_in
    conversation = ConversationItem.find(params[:cid], params:{conversation_id: params[:conversation_id]})
    params[:conversation_item] = {}
    params[:conversation_item][:id] = params[:conversation_item_id]
    params[:conversation_item][:invitees] = conversation.invitees.present? ? conversation.invitees  + ', ' + "#{current_user.email}" : current_user.email
    conversation.update_attributes(request: :update, conversation_item: params[:conversation_item], conversation_id: params[:conversation_id], reload: true)
    render json: conversation
  end

  def add_note
    c_id = Account.find(conversation_item_params[:account_id]).conversation.id
    ci = ConversationItem.create(conversation_item: { title: conversation_item_params[:subject], body: conversation_item_params[:body], scheduled_at: params[:conversation_item][:scheduled_at], created_by_id: current_user.id }, conversation_id: c_id, type: conversation_item_params[:type])
    if ci
      flash[:success] = 'Your note has been added to the conversation!'
    else
      flash[:danger] = 'Oops! Unable to add note.'
    end

    redirect_to account_path(conversation_item_params[:account_id])
  end

  def add_quote
    c_id = @account.conversation.id
    if params[:expires_in].present?
      new_date = Date.today + params[:expires_in].to_i.day
      params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, new_date)
    elsif params[:expires_after].present?
      params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:expires_after])
    end
    if params[:follow_date].present? && params[:follow_time].present?
      params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:follow_date], params[:follow_time])
    end
    check_daylight   #call to check daylight
    ci = ConversationItem.create(conversation_item: { title: conversation_item_params[:title], ends_at: conversation_item_params[:ends_at], body: conversation_item_params[:body], reminder: conversation_item_params[:reminder], scheduled_at: params[:conversation_item][:scheduled_at], status: conversation_item_params[:status], amount: conversation_item_params[:amount], item_type: conversation_item_params[:item_type], created_by_id: current_user.id}, conversation_id: c_id, type: conversation_item_params[:type])
    if ci
      flash[:success] = 'Your quote has been added to the conversation'
    else
      flash[:danger] = 'Oops! Unable to add quote'
    end
    if params[:add_from_schedule].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def update_quote
    conversation_id = @account.conversation.id
    unless params[:conversation_item][:status].present?
      if params[:expires_in].present?
        new_date = Date.today + params[:expires_in].to_i.day
        params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, new_date)
      elsif params[:expires_after].present?
        params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:expires_after])
      end
      if params[:follow_date].present? && params[:follow_time].present?
        params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:follow_date], params[:follow_time])
      else
        params[:conversation_item][:scheduled_at] = nil
      end
    end
    check_daylight   #call to check daylight
    @conversation = ConversationItem.find(params[:conversation_item][:id], params: { conversation_id: @account.conversation.id })
    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id)
      flash[:success] = 'Quote successfully updated!'
    else
      flash[:danger] = 'Quote not updated!'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def delete_quote
    @conversation = ConversationItem.find(params[:item_id], params: { conversation_id: @account.conversation.id })
    if @conversation.destroy
      flash[:success] = 'Quote successfully deleted'
    else
      flash[:danger] = 'Oops! Unable to delete the quote'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end


  def update_note
    conversation_id = @account.conversation.id
    @conversation = ConversationItem.find(params[:conversation_item][:id], params:{conversation_id: @account.conversation.id})
    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id)
      flash[:success] = 'Note successfully updated!'
    else
      flash[:danger] = 'Note not updated!'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def delete_note
    @conversation = ConversationItem.find(params[:item_id], params:{conversation_id: @account.conversation.id})
    if @conversation.destroy
      flash[:success] = 'Note successfully deleted!'
    else
      flash[:danger] = 'Oops! Unable to delete the note.'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def add_reminder
    c_id = @account.conversation.id
    params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time]) if params[:scheduled_date].present? && params[:scheduled_time].present?
    check_daylight   #call to check daylight
    ci = ConversationItem.create(conversation_item: { title: conversation_item_params[:subject], body: conversation_item_params[:body], scheduled_at: params[:conversation_item][:scheduled_at], created_by_id: current_user.id, notify_by_sms: params[:conversation_item][:notify_by_sms], notify_by_email: params[:conversation_item][:notify_by_email], users_to_notify_ids: params[:conversation_item][:users_to_notify_ids] }, conversation_id: c_id, type: conversation_item_params[:type])
    if ci
      flash[:success] = 'Your reminder has been added to the conversation!'
    else
      flash[:danger] = 'Oops! Unable to add reminder.'
    end
    if params[:add_from_schedule].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def update_reminder
    conversation_id = @account.conversation.id
    params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time]) if params[:scheduled_date].present? && params[:scheduled_time].present?
    check_daylight   #call to check daylight
    unless params[:conversation_item][:notify_by_email].present?
      params[:conversation_item][:notify_by_email] = nil
    end

    unless params[:conversation_item][:notify_by_sms].present?
      params[:conversation_item][:notify_by_sms] = nil
    end

    @conversation_item = ConversationItem.find(params[:conversation_item][:id], params: { conversation_id: conversation_id })
    if @conversation_item.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id)
      flash[:success] = 'Reminder successfully updated!'
    else
      flash[:danger] = 'Reminder not updated!'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def delete_reminder
    @conversation = ConversationItem.find(params[:item_id], params: { conversation_id: @account.conversation.id })
    if @conversation.destroy
      flash[:success] = 'Reminder successfully deleted!'
    else
      flash[:danger] = 'Oops! Unable to delete the reminder.'
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
  end

  def send_email
    c_id = Account.find(conversation_item_params[:account_id]).conversation.id
    if params[:scheduled_date].present? && params[:scheduled_time].present?
      params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
    else
      params[:conversation_item][:scheduled_at] = nil
      params[:conversation_item][:reminder] = nil
    end
    check_daylight   #call to check daylight
    ci = ConversationItem.create(
      conversation_item: {
        title: conversation_item_params[:title],
        body: conversation_item_params[:body],
        invitees: conversation_item_params[:email],
        scheduled_at: params[:conversation_item][:scheduled_at],
        created_by_id: current_user.id,
        },
      conversation_id: c_id, type: 'email')
    if ci
      flash[:success] = 'Your email has been successfully sent!'
    else
      flash[:danger] = 'Oops! Looks like there was a problem sending your email.'
    end
    redirect_to account_path(conversation_item_params[:account_id])
  end

  def update_email
    conversation_id = @account.conversation.id
    if params[:conversation_item][:send_later].present?
      if params[:scheduled_date].present? && params[:scheduled_time].present?
        params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
      end
    else
      params[:conversation_item][:scheduled_at] = nil
      params[:conversation_item][:reminder] = nil
    end
    check_daylight   #call to check daylight
    @conversation = ConversationItem.find(params[:conversation_item][:id], params:{conversation_id: @account.conversation.id})
    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id)
      flash[:success] = 'Email successfully updated!'
    else
      flash[:danger] = 'Email not updated!'
    end
    redirect_to account_path(params[:id])
  end

  def delete_email
    @conversation = ConversationItem.find(params[:item_id], params:{conversation_id: @account.conversation.id})
    if @conversation.destroy
      flash[:success] = 'Email successfully deleted!'
    else
      flash[:danger] = 'Oops! Unable to delete the email.'
    end
    redirect_to account_path(params[:id])
  end

  def share
    if params[:account].present? && params[:account][:user_account_sharings_attributes].present?
      params[:account][:user_account_sharings_attributes] = params[:account][:user_account_sharings_attributes].values
      if @account.update_attributes(request: :update, account: shared_account_params)
        flash[:success] = 'Shared users updated successfully!'
      else
        flash[:danger] = 'Oops! Unable updated the shared users.'
      end
    end
    redirect_to account_path(params[:id])
  end

  def search
    c_id = @account.conversation.id
    s_date = Chronic.parse(params[:search][:date_gteq])
    e_date = Chronic.parse(params[:search][:date_lteq])
    s_date = s_date.in_time_zone(current_user.time_zone).strftime("%Y-%m-%d") rescue nil
    e_date = e_date.in_time_zone(current_user.time_zone).strftime("%Y-%m-%d") rescue nil
    search = Hash.new
    if params[:search][:type_cont] == 'meeting'
      search[:starts_at_gteq] = convert_datetime_to_utc(current_user.time_zone, s_date) rescue nil
      search[:starts_at_lteq] = convert_datetime_to_utc(current_user.time_zone, e_date) rescue nil
    else
      search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, s_date) rescue nil
      search[:created_at_lteq] = convert_datetime_to_utc(current_user.time_zone, e_date) rescue nil
    end
    search[:title_cont] = params[:search][:title]
    search[:type_cont] = params[:search][:type_cont]
    @conversation_items = ConversationItem.all(params: { conversation_id: c_id, search: search })
  end

  def import
    if request.post?
      @all_status = AccountStatus.all(uid: RequestStore.store[:tenant], reload: true)
      if params[:import_csv].present? && params[:import_csv].content_type == 'text/csv'
        csv_text = File.read(params[:import_csv].tempfile)
        csv = CSV.parse(csv_text)
        csv_validates(csv)
        csv.shift
        if @row_numbers.empty?
          if csv.present?
            csv.each do |row|
              row = row.join(',')
              row = row.gsub(%r{\"}, '')
              row = row.split(',')
              account_params = {}
              account_params[:name] = row[0]
              account_params[:contact_name] = row[1]
              account_params[:contact_title] = row[2]
              @all_status.each do |status|
                if row[3].present? && status.name.capitalize == row[3].capitalize
                  @status_id = status.id
                  break
                end
              end
              account_params[:status_id] = @status_id
              if row[9].present?
                country_by_name = ISO3166::Country.find_country_by_name(row[9])
                row[9] = country_by_name.alpha2 if country_by_name.present?
              end
              account_params[:addresses_attributes] = [street_address: row[4], suite_number: row[5], city: row[6], region: row[7], postcode: row[8], country: row[9]]
              contacts_attributes = {}
              contacts_attributes['phone'] = {name: '', type: 'phone', value: convert_number_to_phone(row[10])} unless row[10].blank?
              contacts_attributes['fax'] = {name: '', type: 'fax', value: convert_number_to_phone(row[11])} unless row[11].blank?
              contacts_attributes['email'] = {name: '', type: 'email', value: row[12]} unless row[12].blank?
              account_params[:contacts_attributes] = contacts_attributes.values
              account_params[:about] = row[13]
              account_params[:quick_facts] = row[14]
              if row[15].blank?
                account_params[:assign_to] = current_user.id
              else
                value = row[15].to_i
                if value != 0
                  account_params[:assign_to] = value
                else
                  all_users = User.find(:all, reload: true)
                  all_users.each do |user|
                    if (user.email == row[15].squish) || (("#{user.first_name}"+' '+"#{user.last_name}") == row[15].squish)
                      account_params[:assign_to] = user.id
                      break
                    end
                  end
                end
              end
              account = Account.new(request: :create, account: account_params)
              account.save
            end
            flash[:success] = "Import Accounts Successful"
            redirect_to accounts_path
          else
            flash[:danger] = "Please Upload the CSV file with the accounts Details"
            redirect_to account_import_path
          end
        else
          render :import
        end
      else
       flash[:danger] = "File you are trying to import does not support csv format"
      end
    end
  end

  def export
  end

  def generate_csv
    page = session[:page].present? ? session[:page].to_i : 1
    if (@search_all_accounts == 'enable' && @role != 'Admin')
      @accounts = Account.all(params: { company_search: session[:company_search], search: session[:search], page: page, per_page: @show_accounts_per_page})
    else
      @accounts = Account.all(params: { search: session[:search], page: page, per_page: @show_accounts_per_page})
    end
    column_names = ['ID', 'Name', 'Contact Name', 'Contact Title', 'Status', 'Address', 'Suite Number', 'City', 'Province', 'Postal Code', 'Country', 'About', 'Quick Facts' ]
    options = {}
    options[:force_quotes] = true
    # options[:col_sep] = params[:option2][:delimiter] == 'other' ? params[:other_option] : params[:option2][:delimiter]
    options[:col_sep] = ','
    CSV.generate(options) do |csv|
      # if params[:option1][:header] == 'true'
      csv << column_names
      # end
      if @accounts.present?
        @accounts.each do |account|
          address = account.addresses.first rescue nil
          csv << [account.id, account.name, account.contact_name, account.contact_title, account.status.try(:name), address.try(:street_address), address.try(:suite_number), address.try(:city), address.try(:region), address.try(:postcode), address.try(:country), account.about, account.quick_facts]
        end
      end
    end
  end

  def csv_template
    send_data generate_csv_template
  end


  def batch
  end

  def batch_notes
    if request.post?
      if params[:import_csv].present? && params[:import_csv].content_type == 'text/csv'
        csv_text = File.read(params[:import_csv].tempfile)
        begin
          csv = CSV.parse(csv_text)
        rescue Exception => e
          @row_numbers = {}
          e = e.to_s
          e = e.gsub('.','')
          e = e.split(' ').last()
          @row_numbers[e] = "Unable to process this line. Check for missing quotations"
          render :batch
          return
        end
        note_csv_validates(csv)
        csv.shift
        if @row_numbers.empty?
          if csv.present?
            csv.each do |row|
              row = row.join(',')
              row = row.gsub(%r{\"}, '')
              row = row.split(',')
              find_account_by_name_or_id(row[0])
              c_id = @account.conversation.id
              ci = ConversationItem.create(conversation_item: { title: row[1], body: row[2],created_by_id: current_user.id }, conversation_id: c_id, type: 'note')
            end
            flash[:success] = "Notes successfully imported"
            redirect_to accounts_path
          else
            flash[:danger] = "Please Upload the CSV file with the notes Details"
            redirect_to account_batch_path
          end
        else
          render :batch
        end
      else
       flash[:danger] = "File you are trying to import does not support csv format"
       redirect_to account_batch_path
      end
    end
  end

  def add_account_properties
    if request.post?
      if params[:import_csv].present? && params[:import_csv].content_type == 'text/csv'
        csv_text = File.read(params[:import_csv].tempfile)
        begin
          csv = CSV.parse(csv_text)
        rescue Exception => e
          @row_numbers = {}
          e = e.to_s
          e = e.gsub('.','')
          e = e.split(' ').last()
          @row_numbers[e] = "Unable to process this line. Check for missing quotations"
          render :add_account_properties
          return
        end
        properties_csv_validates(csv)
        csv.shift
        if @row_numbers.empty?
          if csv.present?
            csv.each do |row|
              row = row.join(',')
              row = row.gsub(%r{\"}, '')
              row = row.split(',')
              find_account_by_name_or_id(row[0])
              account = {}
              account['properties'] = {}
              @account_properties.keys.each_with_index do |prop,i|
                account['properties'][prop] = row[i+1]
              end
              params[:account] = {}
              params[:account][:properties] = account.to_json
              @account.update_attributes(name: @account.name, account: account_params)
            end
            flash[:success] = "Account's properties successfully imported"
            redirect_to accounts_path
          else
            flash[:danger] = "Please Upload the CSV file with the account's properties Details"
            redirect_to account_add_account_properties_path
          end
        else
          render :add_account_properties
        end
      else
       flash[:danger] = "File you are trying to import does not support csv format"
       redirect_to account_add_account_properties_path
      end
    end
  end

  def import_assets
    if request.post?
      if params[:import_csv].present? && params[:import_csv].content_type == 'text/csv'
        csv_text = File.read(params[:import_csv].tempfile)
        begin
          csv = CSV.parse(csv_text)
        rescue Exception => e
          @row_numbers = {}
          e = e.to_s
          e = e.gsub('.','')
          e = e.split(' ').last()
          @row_numbers[e] = "Unable to process this line. Check for missing quotations"
          render :import_assets
          return
        end
        assets_csv_validates(csv)
        csv.shift
        if @row_numbers.empty?
          if csv.present?
            csv.each do |row|
              row = row.join(',')
              row = row.gsub(%r{\"}, '')
              row = row.split(',')
              find_account_by_name_or_id(row[0])
              asset = {}
              asset[:properties] = {}
              @assets.keys.each_with_index do |prop,i|
                asset[:properties][prop] = row[i+3]
              end
              asset[:properties] = asset[:properties].to_json
              asset[:account_id] = @account.id
              asset[:name] = row[1]
              asset[:description] = row[2]
              @asset = Asset.new(request: :create, asset: asset)
              @asset.save!
            end
            flash[:success] = "Assets successfully imported"
            redirect_to accounts_path
          else
            flash[:danger] = "Please Upload the CSV file with the assets Details"
            redirect_to account_import_assets_path
          end
        else
          render :import_assets
        end
      else
       flash[:danger] = "File you are trying to import does not support csv format"
       redirect_to account_import_assets_path
      end
    end
  end

  def properties_csv_template
    send_data generate_properties_csv_template
  end

  def notes_csv_template
    send_data generate_notes_csv_template
  end

  def assets_csv_template
    send_data generate_assets_csv_template
  end

  private

  def find_account_by_name_or_id(row_value)
    if row_value.to_i != 0
      @account = Account.find(row_value.to_i)
    else
      accounts = Account.all
      if accounts.meta["total_pages"] > 1
        accounts = Account.all(params: { per_page: accounts.meta["total_entries"] })
      end
      accounts.each do |a|
        if a.name == row_value
          @account  = Account.find(a.id)
          break
        end
      end
    end
  end

  def check_account_validation(row)
    if row[0].blank?
      @row_numbers["#{@line_no}"] = "Required field, Account, can not be empty"
    else
      if row[0].to_i != 0
        account = Account.find(row[0].to_i) rescue nil
        if account.blank?
          @row_numbers["#{@line_no}"] = "Account's name/id does not exist in the system"
        end
      else
        accounts = Account.all
        if accounts.meta["total_pages"] > 1
          accounts = Account.all(params: { per_page: accounts.meta["total_entries"] })
        end
        unless accounts.map(&:name).include?row[0]
          @row_numbers["#{@line_no}"] = "Account's name/id does not exist in the system"
        end
      end
    end
  end

  def check_daylight
    if @daylight_setting == 'enable'
      if params[:conversation_item][:starts_at].present?
        starts_at = Chronic.parse(params[:conversation_item][:starts_at]).in_time_zone(current_user.time_zone)
        starts_at = starts_at - 1.hour if starts_at.dst?
        params[:conversation_item][:starts_at] = starts_at
      end
      if params[:conversation_item][:ends_at].present?
        ends_at = Chronic.parse(params[:conversation_item][:ends_at]).in_time_zone(current_user.time_zone)
        ends_at = ends_at - 1.hour if ends_at.dst?
        params[:conversation_item][:ends_at] = ends_at
      end
      if params[:conversation_item][:scheduled_at].present?
        scheduled_at = Chronic.parse(params[:conversation_item][:scheduled_at]).in_time_zone(current_user.time_zone)
        scheduled_at = scheduled_at - 1.hour if scheduled_at.dst?
        params[:conversation_item][:scheduled_at] = scheduled_at
      end
    end
  end

  def convert_number_to_phone(number)
    number = number.to_s
    if number.present?
      if number.include?'ext'
        split_number = number.split("ext")
        number = split_number.first
        ext = split_number.last
      elsif number.include?'x'
        split_number = number.split("x")
        number = split_number.first
        ext = split_number.last
      else
        ext = nil
      end
      if number.length > 10 && number[0] == '1'
        number = number.reverse.chop.reverse
        number = ActionController::Base.helpers.number_to_phone(number, country_code: 1)
        number = "#{number},#{ext}" if ext.present?
      else
        number = ActionController::Base.helpers.number_to_phone(number)
        number = "#{number},#{ext}" if ext.present?
      end
    else
      number = ''
    end

    return number
  end

  def get_setting
     get_account_display_setting
     @role = current_user.roles.last.name
  end

  def check_permission_for_import
    unless(@role == 'Admin' || @role == @enable_import.tr("_", " ").titleize || @enable_import == 'all')
      redirect_to dashboard_path
    end
  end

  def check_permission_for_export
    unless(@role == 'Admin' || @role == @enable_export.tr("_", " ").titleize || @enable_export == 'all')
      redirect_to dashboard_path
    end
  end

  def accounts_statistics_info
    account_statuses = AccountStatus.all(uid: RequestStore.store[:tenant])
    @accounts_statistic = {}

    account_statuses.each do |account_status|
      @accounts_statistic[account_status.id] = {}
      @accounts_statistic[account_status.id]['name'] = account_status.name
      @accounts_statistic[account_status.id]['color'] = account_status.color
      @accounts_statistic[account_status.id]['count'] = 0
    end
    @accounts_statistic[0] = {}
    @accounts_statistic[0]['name'] = 'No Status'
    @accounts_statistic[0]['color'] = "#ffffff"
    @accounts_statistic[0]['count'] = 0

    @accounts.each do |account|
      if account.status.nil?
        @accounts_statistic[0]['count'] += 1
      else
        if @accounts_statistic.key?(account.status.id)
          @accounts_statistic[account.status.id]['count'] += 1
        else
          @accounts_statistic[0]['count'] += 1
        end
      end
    end
  end

  def generate_csv_template
    column_names = ['Account Name', 'Contact Name', 'Contact Title', 'Status', 'Address', 'Suite Number', 'City', 'Province', 'Postal Code', 'Country', 'Phone', 'Fax', 'Email', 'About', 'Quick Facts' ]
    column_names << 'Owner' if current_user.roles.last.try(:name) == "Admin"
    CSV.generate() do |csv|
      csv << column_names
    end
  end

  def generate_notes_csv_template
    column_names = ['Account', 'Note Title', 'Note Message' ]
    CSV.generate() do |csv|
      csv << column_names
    end
  end

  def generate_assets_csv_template
    column_names = ['Account', 'Asset name', 'Description']
    column_names <<  @assets.keys
    column_names = column_names.flatten
    CSV.generate() do |csv|
      csv << column_names
    end
  end

  def generate_properties_csv_template
    column_names = ['Account']
    column_names <<  @account_properties.keys
    column_names = column_names.flatten
    CSV.generate() do |csv|
      csv << column_names
    end
  end

  def assets_csv_validates(csv)
    @line_no = 0
    @row_numbers = {}
    column_names = ['Account', 'Asset name', 'Description']
    column_names <<  @assets.keys
    column_names = column_names.flatten
    if csv[0].present?
      csv.each do |row|
        @line_no +=1
        if row.present?
          row = row.join(',')
          row = row.gsub(%r{\"}, '')
          row = row.split(',')
        end
        if @line_no == 1 && (row.present? && (row !=column_names))
          @row_numbers["#{@line_no}"] = "Imported CSV file does not contain the correct headers"
        end
        if @line_no !=1 && row.present?
          check_account_validation(row)
          if row[1].blank?
            @row_numbers["#{@line_no}"] = "Required field, Asset Name, can not be empty"
          end
        end
      end
    end
  end

  def properties_csv_validates(csv)
    @line_no = 0
    @row_numbers = {}
    column_names = ['Account']
    column_names <<  @account_properties.keys
    column_names = column_names.flatten
    if csv[0].present?
      csv.each do |row|
        @line_no +=1
        if row.present?
          row = row.join(',')
          row = row.gsub(%r{\"}, '')
          row = row.split(',')
        end
        if @line_no == 1 && (row.present? && (row !=column_names))
          @row_numbers["#{@line_no}"] = "Imported CSV file does not contain the correct headers"
        end
        if @line_no !=1 && row.present?
          check_account_validation(row)
        end
      end
    end
  end

  def note_csv_validates(csv)
    @line_no = 0
    @row_numbers = {}
    column_names = ['Account', 'Note Title', 'Note Message' ]
    if csv[0].present?
      csv.each do |row|
        @line_no +=1
        if row.present?
          row = row.join(',')
          row = row.gsub(%r{\"}, '')
          row = row.split(',')
        end
        if @line_no == 1 && (row.present? && (row !=column_names))
          @row_numbers["#{@line_no}"] = "Imported CSV file does not contain the correct headers"
        end
        if @line_no !=1 && row.present?
          check_account_validation(row)
          if row[1].blank?
            @row_numbers["#{@line_no}"] = "Required field, Note Title, can not be empty"
          end
          if row[2].blank?
            @row_numbers["#{@line_no}"] = "Required field, Note Message, can not be empty"
          end
        end
      end
    end
  end

  def csv_validates(csv)
    @line_no = 0
    @row_numbers = {}
    status_array = @all_status.map(&:name)
    column_names = ['Account Name', 'Contact Name', 'Contact Title', 'Status', 'Address', 'Suite Number', 'City', 'Province', 'Postal Code', 'Country', 'Phone', 'Fax', 'Email', 'About', 'Quick Facts' ]
    column_names << "Owner" if current_user.roles.last.try(:name) == "Admin"
    if csv[0].present?
      csv.each do |row|
        @line_no +=1
        if row.present?
          row = row.join(',')
          row = row.gsub(%r{\"}, '')
          row = row.split(',')
        end
        if @line_no == 1 && (row.present? && (row !=column_names))
          @row_numbers["#{@line_no}"] = "Imported CSV file does not contain the correct headers"
        end
        if @line_no !=1 && row.present?
          if row[0].blank?
            @row_numbers["#{@line_no}"] = "Required field, Name, can not be empty"
          end
          if row[3].present?
            if !(status_array.include?(row[3].capitalize))
              @row_numbers["#{@line_no}"] = "Unknown account status"
            end
          else
            @row_numbers["#{@line_no}"] = "Required field, Status, can not be empty"
          end
          unless row[9].blank?
             country = ISO3166::Country.find_country_by_name(row[9]) || ISO3166::Country.find_country_by_alpha2(row[9])
             @row_numbers["#{@line_no}"] = "Country name not found" if country.blank?
          end
          # if row[10].blank?
          #    @row_numbers["#{@line_no}"] = "Missing contact phone number"
          # end
          unless row[12].blank?
             email_reg_exp = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
             is_valid = row[12] =~ email_reg_exp
             # is_valid = row_data[11] =~ email_reg_exp
             @row_numbers["#{@line_no}"] = "Invalid Email" if is_valid.blank?
          end
          unless row[15].blank?
            value = row[15].to_i
            if value != 0
              user = User.find(row[15].to_i) rescue nil
              if user.blank?
                @row_numbers["#{@line_no}"] = "Owner Field: ID not found"
              end
            else
              email_reg_exp = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
              is_valid = row[15].squish =~ email_reg_exp
              @all_users = User.find(:all, reload: true)
              if is_valid.blank?
                users_name = @all_users.map{|u| "#{u.first_name}"+' '+"#{u.last_name}"}
                unless users_name.include?row[15].squish
                  @row_numbers["#{@line_no}"] = "Owner Field: Unknown Name or Email"
                end
              else
                users_email = @all_users.map(&:email)
                unless users_email.include?row[15].squish
                  @row_numbers["#{@line_no}"] = "Owner Field: Unknown Name or Email"
                end
              end
            end
          end
        end
      end
    end
  end

  def account_timeline_conversation_items
    @user_preference = user_preferences_load
    preference_limit = @user_preference['preview_conversation_timeline']
    user_ids = Array.new
    search = Hash.new
    user_ids.push(current_user.id)
    current_date = Date.current.in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
    search[:created_at_lteq] = convert_datetime_to_utc(current_user.time_zone, current_date, "23:59:59")
    search[:conversation_id_eq] = @account.conversation.id.to_i
    if preference_limit.present?
      if preference_limit == 'one_day'
        search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, current_date, "00:00:00")
      elsif preference_limit == 'two_days'
        end_date = (Date.current - 1.day).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
        search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
      elsif preference_limit == 'one_week'
        end_date = (Date.current - 1.week).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
        search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
      elsif preference_limit == 'two_weeks'
        end_date = (Date.current - 2.week).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
        search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
      elsif preference_limit == 'one_month'
        end_date = (Date.current - 1.month).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
        search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
      end
      @timeline_items = ConversationItemSearch.all(params: {user_ids: user_ids, search: search})
    else
      @timeline_items = @account.conversation.conversation_items
    end
  end

  # def accounts_sort_by(value1, value2)
  #   if value1 == 'name'
  #     @accounts = @accounts.sort_by { |a| [a.name] }
  #   elsif value1 == 'city'
  #     @accounts = @accounts.sort_by { |a| [a.city_name] }
  #   elsif value1 == 'country'
  #     @accounts = @accounts.sort_by { |a| [a.country_name] }
  #   elsif value1 == 'owner'
  #     @accounts = @accounts.sort_by { |a| [a.assigned_to.try(:first_name)] }
  #   elsif value1 == 'estimated_sales'
  #     @accounts = @accounts.sort_by { |a| [a.expected_sales.to_f] }
  #   end
  #   @accounts = @accounts.reverse if value2 == 'descending'
  #   session[:search1] = value1
  #   session[:search2] = value2
  #   session[:sort_val1_for_page] = value1
  #   session[:sort_val2_for_page] = value2
  # end

  def advanced_search
    @search = {}
    if params[:rule].present?
      params[:rule].values.each do |r|
        if r['option'] == "name"
          if r['is_contain'] == 'contains'
             @search[:name_cont] =  r['text']
          else
            @search[:name_eq] =  r['text']
          end
        elsif r['option'] == "city"
          if r['is_contain'] == 'contains'
             @search[:addresses_city_cont] =  r['text']
          else
            @search[:addresses_city_eq] =  r['text']
          end
        elsif r['option'] == "status"
          if r['is_contain'] == 'contains'
             @search[:status_name_cont] =  r['status']
          else
            @search[:status_name_eq] =  r['status']
          end
        elsif r['option'] == "owner"
          if r['is_contain'] == 'contains'
             @search[:assigned_to_first_name_or_assigned_to_last_name_cont] =  r['text']
          else
            @search[:assigned_to_first_name_or_assigned_to_last_name_eq] =  r['text']
          end
        end
      end
      @search[:m] = 'or' if params[:match] == 'any'
    end
  end

  def get_token
    # set gloal var for token to be used in model, hack for now
    RequestStore.store[:user_token]
  end

  def conversation_item_params
    params.require(:conversation_item).permit(:account_id, :type, :reminder, :scheduled_at, :subject, :body, :email, :send_later, :title, :status, :amount, :item_type, :ends_at)
  end

  def account_params
    params.require(:account).permit(
      :name, :status_id, :properties, :contact_name, :expected_sales, :contact_title, :assign_to, :shared_with, :about, :quick_facts, :avatar,
      addresses_attributes: [:id, :name, :street_address, :suite_number, :postcode, :city, :region, :latitude, :longitude, :country, :_destroy],
      contacts_attributes: [:id, :type, :name, :value, :_destroy]
    )
  end

  def asset_params
    params.require(:asset).permit([:name, :description, :account_id, :properties])
  end

  def shared_account_params
    params.require(:account).permit(
      user_account_sharings_attributes: [:user_id, :permission, :_destroy]
    )
  end

  def find_account
    @account = Account.find(params[:id])
  end

  def get_api_values
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end

  def save_avatar
    if params.key?(:avatar)
      url = URI.parse("#{RequestStore.store[:api_url]}/accounts/#{@account.id}")
      puts "sending avatar...#{url}"
      req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:avatar].tempfile), 'image/jpeg', 'image.jpg')
      req.add_field('Authorization', "Token token=\"#{RequestStore.store[:user_token]}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")

      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end
    end
  end

  def account_update_info(account_with_previous_value, account_with_update_value)
    changed_value = {}
    if account_with_previous_value.present? && account_with_update_value.present?
      if account_with_previous_value.name != account_with_update_value.name
        changed_value[:prev_name] = account_with_previous_value.name
        changed_value[:updated_name] = account_with_update_value.name
      end
      if account_with_previous_value.expected_sales != account_with_update_value.expected_sales
        changed_value[:prev_expected_sales] = account_with_previous_value.expected_sales
        changed_value[:updated_expected_sales] = account_with_update_value.expected_sales
      end
      if account_with_previous_value.status.name != account_with_update_value.status.name
        changed_value[:prev_status] = account_with_previous_value.status.name
        changed_value[:updated_status] = account_with_update_value.status.name
      end
      if account_with_previous_value.contact_name != account_with_update_value.contact_name
        changed_value[:prev_contact_name] = account_with_previous_value.contact_name
        changed_value[:updated_contact_name] = account_with_update_value.contact_name
      end
      if account_with_previous_value.contact_title != account_with_update_value.contact_title
        changed_value[:prev_contact_title] = account_with_previous_value.contact_title
        changed_value[:updated_contact_title] = account_with_update_value.contact_title
      end
      if account_with_previous_value.id != account_with_update_value.id
        changed_value[:prev_assigned_to] = account_with_previous_value.assigned_to.first_name + ' ' + account_with_previous_value.assigned_to.last_name
        changed_value[:updated_assigned_to] = account_with_update_value.assigned_to.first_name + ' ' + account_with_update_value.assigned_to.last_name
      end
      if account_with_previous_value.id != account_with_update_value.id
        changed_value[:prev_assigned_to] = account_with_previous_value.assigned_to.first_name + ' ' + account_with_previous_value.assigned_to.last_name
        changed_value[:updated_assigned_to] = account_with_update_value.assigned_to.first_name + ' ' + account_with_update_value.assigned_to.last_name
      end

      prev_address = account_with_previous_value.addresses.first
      updated_address = account_with_update_value.addresses.first
      if prev_address.name != updated_address.name
         changed_value[:prev_address_name] = prev_address.name
         changed_value[:updated_address_name] = updated_address.name
      end
      if prev_address.street_address != updated_address.street_address
         changed_value[:prev_address_street_address] = prev_address.street_address
         changed_value[:updated_address_street_address] = updated_address.street_address
      end
      if prev_address.city != updated_address.city
         changed_value[:prev_address_city] = prev_address.city
         changed_value[:updated_address_city] = updated_address.city
      end
      if prev_address.postcode != updated_address.postcode
         changed_value[:prev_address_postcode] = prev_address.postcode
         changed_value[:updated_address_postcode] = updated_address.postcode
      end
      if prev_address.region != updated_address.region
         changed_value[:prev_address_region] = prev_address.region
         changed_value[:updated_address_region] = updated_address.region
      end
      if prev_address.country != updated_address.country
         changed_value[:prev_address_country] = prev_address.country
         changed_value[:updated_address_country] = updated_address.country
      end
      if account_with_previous_value.about != account_with_update_value.about
        changed_value[:prev_about] = account_with_previous_value.about
        changed_value[:updated_about] = account_with_update_value.about
      end
      if account_with_previous_value.quick_facts != account_with_update_value.quick_facts
        changed_value[:prev_quick_facts] = account_with_previous_value.quick_facts
        changed_value[:updated_quick_facts] = account_with_update_value.quick_facts
      end
      prev_phone = []
      prev_mobile = []
      prev_email = []
      prev_facebook = []
      prev_twitter = []
      prev_fax = []
      prev_youtube = []
      prev_website = []
      prev_contacts = account_with_previous_value.contacts
      if prev_contacts.count > 0
        prev_contacts.each do |contact|
          if contact.type == "phone"
            prev_phone << contact.value
          elsif contact.type == "mobile"
            prev_mobile << contact.value
          elsif contact.type == "email"
            prev_email << contact.value
          elsif contact.type == "facebook"
            prev_facebook << contact.value
          elsif contact.type == "twitter"
            prev_twitter << contact.value
          elsif contact.type == "fax"
            prev_fax << contact.value
          elsif contact.type == "youtube"
            prev_youtube << contact.value
          elsif contact.type == "website"
            prev_website << contact.value
          end
        end
      end
      updated_phone = []
      updated_mobile = []
      updated_email = []
      updated_facebook = []
      updated_twitter = []
      updated_fax = []
      updated_youtube = []
      updated_website = []
      updated_contacts = account_with_update_value.contacts
      if updated_contacts.count > 0
        updated_contacts.each do |contact|
          if contact.type == "phone"
            updated_phone << contact.value
          elsif contact.type == "mobile"
            updated_mobile << contact.value
          elsif contact.type == "email"
            updated_email << contact.value
          elsif contact.type == "facebook"
            updated_facebook << contact.value
          elsif contact.type == "twitter"
            updated_twitter << contact.value
          elsif contact.type == "fax"
            updated_fax << contact.value
          elsif contact.type == "youtube"
            updated_youtube << contact.value
          elsif contact.type == "website"
            updated_website << contact.value
          end
        end
      end
      if prev_phone.sort != updated_phone.sort
        changed_value[:prev_phone] = prev_phone.join(',')
        changed_value[:updated_phone] = updated_phone.join(',')
      end
      if prev_mobile.sort != updated_mobile.sort
        changed_value[:prev_mobile] = prev_mobile.join(',')
        changed_value[:updated_mobile] = updated_mobile.join(',')
      end
      if prev_email.sort != updated_email.sort
        changed_value[:prev_email] = prev_email.join(',')
        changed_value[:updated_email] = updated_email.join(',')
      end
      if prev_facebook.sort != updated_facebook.sort
        changed_value[:prev_facebook] = prev_facebook.join(',')
        changed_value[:updated_facebook] = updated_facebook.join(',')
      end
      if prev_twitter.sort != updated_twitter.sort
        changed_value[:prev_twitter] = prev_twitter.join(',')
        changed_value[:updated_twitter] = updated_twitter.join(',')
      end
      if prev_fax.sort != updated_fax.sort
        changed_value[:prev_fax] = prev_fax.join(',')
        changed_value[:updated_fax] = updated_fax.join(',')
      end
      if prev_youtube.sort != updated_youtube.sort
        changed_value[:prev_youtube] = prev_youtube.join(',')
        changed_value[:updated_youtube] = updated_youtube.join(',')
      end
      if prev_website.sort != updated_website.sort
        changed_value[:prev_website] = prev_website.join(',')
        changed_value[:updated_website] = updated_website.join(',')
      end
    end
    @note_body = "<p><b>Previous Value => Updated Value</b></p><ul>#{changed_value[:prev_name].present? ? "<li> <b>Account Name:</b> #{changed_value[:prev_name]} => #{changed_value[:updated_name]} </li>" : ''}#{changed_value[:prev_status].present? ? "<li> <b>Account Status:</b> #{changed_value[:prev_status]} => #{changed_value[:updated_status]} </li>" : ''}#{changed_value[:prev_contact_name].present? ? "<li> <b>Contact Name:</b> #{changed_value[:prev_contact_name]} => #{changed_value[:updated_contact_name]} </li>" : ''}#{changed_value[:prev_contact_title].present? ? "<li> <b>Contact Title:</b> #{changed_value[:prev_contact_title]} => #{changed_value[:updated_contact_title]} </li>" : ''}#{changed_value[:prev_expected_sales].present? ? "<li> <b>Expected Sales:</b> #{changed_value[:prev_expected_sales]} => #{changed_value[:updated_expected_sales]} </li>" : ''}#{changed_value[:prev_assigned_to].present? ? "<li> <b>Assign To:</b> #{changed_value[:prev_assigned_to]} => #{changed_value[:updated_assigned_to]} </li>" : ''}#{changed_value[:prev_address_name].present? ? "<li> <b>Address Name:</b> #{changed_value[:prev_address_name]} => #{changed_value[:updated_address_name]} </li>" : ''}#{changed_value[:prev_address_street_address].present? ? "<li> <b>Street Address:</b> #{changed_value[:prev_address_street_address]} => #{changed_value[:updated_address_street_address]} </li>" : ''}#{changed_value[:prev_address_city].present? ? "<li> <b>City:</b> #{changed_value[:prev_address_city]} => #{changed_value[:updated_address_city]} </li>" : ''}#{changed_value[:prev_address_postcode].present? ? "<li> <b>Post/Zipcode:</b> #{changed_value[:prev_address_postcode]} => #{changed_value[:updated_address_postcode]} </li>" : ''}#{changed_value[:prev_address_region].present? ? "<li> <b>Province/State:</b> #{changed_value[:prev_address_region]} => #{changed_value[:updated_address_region]} </li>" : ''}#{changed_value[:prev_address_country].present? ? "<li> <b>Country:</b> #{changed_value[:prev_address_country]} => #{changed_value[:updated_address_country]} </li>" : ''}#{changed_value[:prev_about].present? ? "<li> <b>About:</b> #{changed_value[:prev_about]} => #{changed_value[:updated_about]} </li>" : ''}#{changed_value[:prev_phone].present? ? "<li> <b>Phone Number:</b> #{changed_value[:prev_phone]} => #{changed_value[:updated_phone]} </li>" : ''}#{changed_value[:prev_mobile].present? ? "<li> <b>Mobile Number:</b> #{changed_value[:prev_mobile]} => #{changed_value[:updated_mobile]} </li>" : ''}#{changed_value[:prev_email].present? ? "<li> <b>Email:</b> #{changed_value[:prev_email]} => #{changed_value[:updated_email]} </li>" : ''}#{changed_value[:prev_facebook].present? ? "<li> <b>Facebook:</b> #{changed_value[:prev_facebook]} => #{changed_value[:updated_facebook]} </li>" : ''}#{changed_value[:prev_twitter].present? ? "<li> <b>Twitter:</b> #{changed_value[:prev_twitter]} => #{changed_value[:updated_twitter]} </li>" : ''}#{changed_value[:prev_fax].present? ? "<li> <b>Fax:</b> #{changed_value[:prev_fax]} => #{changed_value[:updated_fax]} </li>" : ''}#{changed_value[:prev_youtube].present? ? "<li> <b>Youtube:</b> #{changed_value[:prev_youtube]} => #{changed_value[:updated_youtube]} </li>" : ''}#{changed_value[:prev_website].present? ? "<li> <b>Website:</b> #{changed_value[:prev_website]} => #{changed_value[:updated_website]} </li>" : ''}#{changed_value[:prev_quick_facts].present? ? "<li> <b>Quick Facts:</b> #{changed_value[:prev_quick_facts]} => #{changed_value[:updated_quick_facts]} </li>" : ''}#{(changed_value[:prev_phone].blank? && changed_value[:updated_phone].present?) || (changed_value[:prev_mobile].blank? && changed_value[:updated_mobile].present?) ||(changed_value[:prev_email].blank? && changed_value[:updated_email].present?) ||(changed_value[:prev_facebook].blank? && changed_value[:updated_facebook].present?) ||(changed_value[:prev_twitter].blank? && changed_value[:updated_twitter].present?) ||(changed_value[:prev_youtube].blank? && changed_value[:updated_youtube].present?) ||(changed_value[:prev_website].blank? && changed_value[:updated_website].present?) ||(changed_value[:prev_fax].blank? && changed_value[:updated_fax].present?) ? "<li style=list-style-type: none;><b>New Contact(s) Added</b></li>" : ''}#{(changed_value[:prev_phone].blank? && changed_value[:updated_phone].present?) ? "<li> <b>Phone:</b> #{changed_value[:updated_phone]} </li>" : ''}#{(changed_value[:prev_mobile].blank? && changed_value[:updated_mobile].present?) ? "<li> <b>Mobile:</b> #{changed_value[:updated_mobile]} </li>" : ''}#{(changed_value[:prev_email].blank? && changed_value[:updated_email].present?) ? "<li> <b>Email:</b> #{changed_value[:updated_email]} </li>" : ''}#{(changed_value[:prev_facebook].blank? && changed_value[:updated_facebook].present?) ? "<li> <b>Facebook:</b> #{changed_value[:updated_facebook]} </li>" : ''}#{(changed_value[:prev_twitter].blank? && changed_value[:updated_twitter].present?) ? "<li> <b>Twitter:</b> #{changed_value[:updated_twitter]} </li>" : ''}#{(changed_value[:prev_youtube].blank? && changed_value[:updated_youtube].present?) ? "<li> <b>Youtube:</b> #{changed_value[:updated_youtube]} </li>" : ''}#{(changed_value[:prev_website].blank? && changed_value[:updated_website].present?) ? "<li> <b>Website:</b> #{changed_value[:updated_website]} </li>" : ''}#{(changed_value[:prev_fax].blank? && changed_value[:updated_fax].present?) ? "<li> <b>Fax:</b> #{changed_value[:updated_fax]} </li>" : ''}</ul><p><b>Updated by:</b> #{current_user.first_name} #{current_user.last_name} </p>".html_safe
     return @note_body
  end
end
