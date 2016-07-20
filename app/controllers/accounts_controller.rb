require 'net/http/post/multipart'
include ApplicationHelper
class AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:delete_future_meeting, :destroy]
  before_action :get_token
  before_action :find_account, only: [:show, :edit, :destroy, :conversation, :search, :jump_in, :add_quote, :edit, :update, :share, :update_note, :update_email, :delete_note, :delete_email, :schedule_meeting, :delete_meeting, :update_meeting, :delete_future_meeting, :update_quote, :delete_quote, :add_reminder, :update_reminder, :delete_reminder]
  before_action :get_api_values, only: [:search]
  before_action :get_setting, only: [:index, :import, :export, :show, :edit, :new]
  before_action :check_permission_for_import, only: [:import]
  before_action :check_permission_for_export, only: [:export]
  @@account_with_previous_value = nil

  def index
    user_preference_details
    show_accounts_per_page = @user_preference['show_accounts_per_page']
    @show_accounts_per_page = show_accounts_per_page.to_i > 0 ? show_accounts_per_page.to_i : 25
    page = params[:page].present? ? params[:page] : 1
    # Get all accounts
    if request.format.symbol.present? && [:csv,:xls].exclude?(request.format.symbol)
      session[:search1] = nil
      session[:search2] = nil
      session[:search] = nil
      session[:advanced_search] = nil
    end
    @accounts = Account.all(params: { search: params[:search],page: page, per_page: @show_accounts_per_page })
    @total_entries = @accounts.total_entries
    session[:search] = params[:search] if params[:search].present?
    if params[:search1].present? && params[:search2].present?
      accounts_sort_by(params[:search1][:search], params[:search2][:search])
      session[:search1] = params[:search1][:search]
      session[:search2] = params[:search2][:search]
    end
    if params[:advanced_search].present?
      advanced_search
      session[:advanced_search] = @search
      @accounts = Account.all(params: { search: @search, page: page, per_page: @show_accounts_per_page })
      @total_entries = @accounts.total_entries
    end
    accounts_statistics_info
    respond_to do |format|
      format.html
      if request.format.symbol == :csv
        format.csv { send_data generate_csv }
      elsif request.format.symbol == :xls
        format.xls { send_data generate_csv }
      end
    end
  end

  def show
    # Get the acount info and conversation based on id given
    @shared_user = []
    @account.user_account_sharings.each { |u| @shared_user << u.user }
    @users = User.all(uid: session[:user_id])
    @notifiable_users = notifiable_users_json(params[:id])
    # if params[:notification_id].present?
    #   @notification = Notification.find(params[:notification_id])
    #   @notification.update_attributes(read_at: Time.now)
    #   notification_info
    # end

    ##account_timeline_conversation_items
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
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
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

  def schedule_meeting
    c_id = @account.conversation.id
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
    if params[:created_by].to_i == current_user.id
      conversation = ConversationItem.find(params[:cid], params:{conversation_id: params[:conversation_id]})
      params[:conversation_item] = {}
      params[:conversation_item][:status] = "in_progress"
      conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: params[:conversation_id], reload: true)
    end
    render json: ci
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
    if params[:created_by].to_i == current_user.id
      conversation = ConversationItem.find(params[:cid], params:{conversation_id: params[:conversation_id]})
      params[:conversation_item] = {}
      params[:conversation_item][:status] = "completed"
      conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: params[:conversation_id], reload: true)
    end
    render json: co
  end

  def jump_in
    c_id = @account.conversation.id
    @meeting = ConversationItem.find(params[:conversation_item_id], params: { conversation_id: c_id })
    params[:conversation_item] = {}
    params[:conversation_item][:id] = params[:conversation_item_id]
    params[:conversation_item][:invitees] = @meeting.invitees.present? ? @meeting.invitees  + ', ' + "#{current_user.email}" : current_user.email
    if @meeting.update_attributes(request: :update, conversation_item: params[:conversation_item], conversation_id: c_id, reload: true)
      flash[:success] = 'successfully jumped!'
    else
      flash[:danger] = "Couldn't jumped!"
    end
    if params[:info].present?
      redirect_to schedule_path
    else
      redirect_to account_path(params[:id])
    end
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
      @all_status = AccountStatus.find(:all)
      if params[:import_csv].present? && params[:import_csv].content_type == 'text/csv'
        csv_text = File.read(params[:import_csv].tempfile)
        csv = CSV.parse(csv_text)
        csv_validates(csv)
        csv.shift
        if @row_numbers.empty?
          if csv.present?
            csv.each do |row|
              row = row[0].gsub(%r{\"}, '')
              row = row.split(',')
              account_params = {}
              account_params[:name] = row[0]
              account_params[:contact_name] = row[1]
              account_params[:contact_title] = row[2]
              @all_status.each do |status|
                if row[3].present? && status.name ==  row[3].capitalize
                  @status_id = status.id
                  break
                end
              end
              account_params[:status_id] = @status_id
              account_params[:addresses_attributes] = [street_address: row[4], city: row[5], region: row[6], postcode: row[7], country: row[8]]
              contacts_attributes = {}
              contacts_attributes['phone'] = {name: '', type: 'phone', value: row[9]}
              contacts_attributes['fax'] = {name: '', type: 'fax', value: row[10]} if row[10].present?
              contacts_attributes['email'] = {name: '', type: 'email', value: row[11]} if row[11].present?
              account_params[:contacts_attributes] = contacts_attributes.values
              account_params[:about] = row[12]
              account_params[:quick_facts] = row[13]
              account_params[:assign_to] = current_user.id
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
      end
    end
  end

  def export
  end

  def generate_csv
    if session[:search1].present? && session[:search2].present?
      accounts_sort_by(session[:search1], session[:search2])
    elsif session[:advanced_search].present?
      @accounts = Account.all(params: { search: session[:advanced_search] })
    else
      @accounts = Account.all(params: { search: session[:search] })
    end
    column_names = ['ID', 'Name', 'Contact Name', 'Contact Title', 'Status', 'Address', 'City', 'Province', 'Postal Code', 'Country', 'About', 'Quick Facts' ]
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
          csv << [account.id, account.name, account.contact_name, account.contact_title, account.status.try(:name), address.try(:street_address), address.try(:city), address.try(:region), address.try(:postcode), address.try(:country), account.about, account.quick_facts]
        end
      end
    end
  end

  def csv_template
    send_data generate_csv_template
  end

  private

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
    column_names = ['Account Name', 'Contact Name', 'Contact Title', 'Status', 'Address', 'City', 'Province', 'Postal Code', 'Country', 'Phone', 'Fax', 'Email', 'About', 'Quick Facts' ]
    CSV.generate() do |csv|
      csv << column_names
    end
  end

  def csv_validates(csv)
    @line_no = 0
    @row_numbers = {}
    status_array = @all_status.map(&:name)
    column_names = ['Account Name', 'Contact Name', 'Contact Title', 'Status', 'Address', 'City', 'Province', 'Postal Code', 'Country', 'Phone', 'Fax', 'Email', 'About', 'Quick Facts' ]
    if csv[0].present?
      csv.each do |row|
        @line_no +=1
        if row[0].present?
          row_data = row[0].gsub(%r{\"}, '')
          row_data = row_data.split(',')
        end
        if @line_no == 1 && (row[0].present? && (row_data !=column_names))
          @row_numbers["#{@line_no}"] = "Imported CSV file does not contain the correct headers"
        end
        if @line_no !=1 && row[0].present?
          if row_data[0].blank?
            @row_numbers["#{@line_no}"] = "Required field, Name, can not be empty"
          end
          if row_data[3].present?
            if !(status_array.include?(row_data[3].capitalize))
              @row_numbers["#{@line_no}"] = "Unknown account status"
            end
          else
            @row_numbers["#{@line_no}"] = "Required field, Status, can not be empty"
          end
          if row_data[9].blank?
             @row_numbers["#{@line_no}"] = "Missing contact phone number"
          end
        end
      end
    end
  end

  def account_timeline_conversation_items
    user_preference_details
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

  def accounts_sort_by(value1, value2)
    if value1 == 'name'
      @accounts = @accounts.sort_by { |a| [a.name] }
    elsif value1 == 'city'
      @accounts = @accounts.sort_by { |a| [a.city_name] }
    elsif value1 == 'country'
      @accounts = @accounts.sort_by { |a| [a.country_name] }
    elsif value1 == 'owner'
      @accounts = @accounts.sort_by { |a| [a.assigned_to.try(:first_name)] }
    elsif value1 == 'estimated_sales'
      @accounts = @accounts.sort_by { |a| [a.expected_sales.to_f] }
    end
    @accounts = @accounts.reverse if value2 == 'descending'
  end

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
      :name, :status_id, :contact_name, :expected_sales, :contact_title, :assign_to, :shared_with, :about, :quick_facts, :avatar,
      addresses_attributes: [:id, :name, :street_address, :postcode, :city, :region, :latitude, :longitude, :country, :_destroy],
      contacts_attributes: [:id, :type, :name, :value, :_destroy]
    )
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

      prev_address = account_with_previous_value.addresses.last
      updated_address = account_with_update_value.addresses.last
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
    end
    @note_body = "<p><b>Previous Value => Updated Value</b></p><ul>#{changed_value[:prev_name].present? ? "<li> <b>Account Name:</b> #{changed_value[:prev_name]} => #{changed_value[:updated_name]} </li>" : ''}#{changed_value[:prev_status].present? ? "<li> <b>Account Status:</b> #{changed_value[:prev_status]} => #{changed_value[:updated_status]} </li>" : ''}#{changed_value[:prev_contact_name].present? ? "<li> <b>Contact Name:</b> #{changed_value[:prev_contact_name]} => #{changed_value[:updated_contact_name]} </li>" : ''}#{changed_value[:prev_contact_title].present? ? "<li> <b>Contact Title:</b> #{changed_value[:prev_contact_title]} => #{changed_value[:updated_contact_title]} </li>" : ''}#{changed_value[:prev_expected_sales].present? ? "<li> <b>Expected Sales:</b> #{changed_value[:prev_expected_sales]} => #{changed_value[:updated_expected_sales]} </li>" : ''}#{changed_value[:prev_assigned_to].present? ? "<li> <b>Assign To:</b> #{changed_value[:prev_assigned_to]} => #{changed_value[:updated_assigned_to]} </li>" : ''}#{changed_value[:prev_address_name].present? ? "<li> <b>Address Name:</b> #{changed_value[:prev_address_name]} => #{changed_value[:updated_address_name]} </li>" : ''}#{changed_value[:prev_address_street_address].present? ? "<li> <b>Street Address:</b> #{changed_value[:prev_address_street_address]} => #{changed_value[:updated_address_street_address]} </li>" : ''}#{changed_value[:prev_address_city].present? ? "<li> <b>City:</b> #{changed_value[:prev_address_city]} => #{changed_value[:updated_address_city]} </li>" : ''}#{changed_value[:prev_address_postcode].present? ? "<li> <b>Post/Zipcode:</b> #{changed_value[:prev_address_postcode]} => #{changed_value[:updated_address_postcode]} </li>" : ''}#{changed_value[:prev_address_region].present? ? "<li> <b>Province/State:</b> #{changed_value[:prev_address_region]} => #{changed_value[:updated_address_region]} </li>" : ''}#{changed_value[:prev_address_country].present? ? "<li> <b>Country:</b> #{changed_value[:prev_address_country]} => #{changed_value[:updated_address_country]} </li>" : ''}#{changed_value[:prev_about].present? ? "<li> <b>About:</b> #{changed_value[:prev_about]} => #{changed_value[:updated_about]} </li>" : ''}#{changed_value[:prev_quick_facts].present? ? "<li> <b>Quick Facts:</b> #{changed_value[:prev_quick_facts]} => #{changed_value[:updated_quick_facts]} </li>" : ''}</ul><p><b>Updated by:</b> #{current_user.first_name} #{current_user.last_name} </p>".html_safe
     return @note_body
  end
end