require 'net/http/post/multipart'
class AccountsController < ApplicationController
  before_action :get_token
  before_action :find_account, only: [:conversation, :search, :jump_in, :edit, :update, :share, :update_note, :update_email, :delete_note, :delete_email, :schedule_meeting, :delete_meeting, :update_meeting]
  before_action :get_api_values,only: [:search]
  def index
    # Get all accounts
    @accounts = Account.all(params: {search: params[:search]})
  end


  def show
    # Get the acount info and conversation based on id given
    @account = Account.find(params[:id])
    @shared_user = []
    @account.user_account_sharings.each {|u| @shared_user << u.user}
    @users = User.all
  end


  def new
    # Add an account
    @account = Account.new
    @users = User.all
  end


  def edit
    # Edit an account
    @account = Account.find(params[:id])
    @addresses = @account.addresses
    @contacts = @account.contacts
    @users = User.all
  end


  def create
    puts "RECEIVED PARAMS = #{account_params}"
    # Create new account
    if params.has_key?(:save)
      #@account = Account.new account_params
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
      params[:account][:addresses_attributes] = params[:account][:addresses_attributes]
      @account = Account.new(request: :create, account: account_params)

      if @account.save
        if params.has_key?(:avatar)
          puts "sending avatar..."
          url = URI.parse("#{ENV.fetch("ORCHARD_API_HOST")}/accounts/#{@account.id}")
          #req = Net::HTTP::Put::Multipart.new url.path,  account: { :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")}
          req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")
          req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
          #req.add_field("Content-Type", "application/json")
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end
        end
        flash[:success] = 'Account has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the account'
      end
    end

    redirect_to accounts_path
  end


  def update
    # Update account
    if params.has_key?(:save)
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
      #params[:account][:addresses_attributes] = params[:account][:addresses_attributes].values
      if @account.update_attributes(name: @account.name, account: account_params)
        flash[:success] = 'Account has been edited successfully'
      else
        flash[:danger] = 'Oops! Unable to edit the account'
      end
    end
    redirect_to account_path(params[:id])
  end


  def schedule_meeting
    c_id = @account.conversation.id
    if params[:scheduled_date].present? && params[:scheduled_time].present?
      params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
    else
      params[:conversation_item][:scheduled_at] = nil
      params[:conversation_item][:reminder] = nil
    end
    params[:conversation_item][:starts_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], params[:starts_time])
    params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:ends_date], params[:ends_time])

    if params[:conversation_item][:repetition_rule][:frequency_type] == "monthly"
       params[:conversation_item][:repetition_rule][:day_of_month] = params[:conversation_item][:starts_at].day if params[:month_week] == "dayofmonth"
       params[:conversation_item][:repetition_rule][:weekday_of_month] = Date::DAYNAMES[params[:conversation_item][:starts_at].wday].first(2).upcase if params[:month_week] == "dayofweek"
       params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_month]
    elsif params[:conversation_item][:repetition_rule][:frequency_type] == "weekly"
       params[:conversation_item][:repetition_rule][:day_of_week] = params[:conversation_item][:repetition_rule][:day_of_week].join(",") if params[:conversation_item][:repetition_rule][:day_of_week].present?
       params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_week]
    elsif params[:conversation_item][:repetition_rule][:frequency_type] == "daily"
       params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_day]
    elsif params[:conversation_item][:repetition_rule][:frequency_type] == "yearly"
         params[:conversation_item][:repetition_rule][:frequency] = params[:conversation_item][:repetition_rule][:repeat_year]
    end

    ci = ConversationItem.create(
          conversation_item: {
            title:              conversation_item_params[:title],
            body:               conversation_item_params[:body],
            invitees:           params[:conversation_item][:invitees],
            scheduled_at:       params[:conversation_item][:scheduled_at],
            location:           params[:conversation_item][:location],
            reminder:           params[:conversation_item][:reminder],
            starts_at:          params[:conversation_item][:starts_at],
            ends_at:            params[:conversation_item][:ends_at],
            repetition_rule: {
            frequency_type:     params[:conversation_item][:repetition_rule][:frequency_type],
            frequency:          params[:conversation_item][:repetition_rule][:frequency],
            repeat_occurrences: params[:conversation_item][:repetition_rule][:repeat_occurrences],
            day_of_week:        params[:conversation_item][:repetition_rule][:day_of_week],
            day_of_month:       params[:conversation_item][:repetition_rule][:day_of_month],
            weekday_of_month:   params[:conversation_item][:repetition_rule][:weekday_of_month]
            }
          },
        conversation_id: c_id, type: "meeting")
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
    meeting = @account.conversation.conversation_items
    meeting.each do |n|
      @conversation = n if n.id == params[:item_id].to_i
    end
    if @conversation.destroy
      flash[:success] = 'Meeting successfully deleted'
    else
      flash[:danger] = 'Oops! Unable to delete the meeting'
    end
    redirect_to account_path(params[:id])
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
    params[:conversation_item][:starts_at] = convert_datetime_to_utc(current_user.time_zone, params[:starts_date], params[:starts_time]) if params[:starts_date] && params[:starts_time]
    params[:conversation_item][:ends_at] = convert_datetime_to_utc(current_user.time_zone, params[:ends_date], params[:ends_time]) if params[:ends_date] && params[:ends_time]
    meeting = @account.conversation.conversation_items
    meeting.each do |n|
      @conversation = n if n.id == params[:conversation_item][:id].to_i
    end
    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id, reload: true)
      flash[:success] = 'Meeting successfully updated!'
    else
      flash[:danger] = 'Meeting not updated!'
    end
    redirect_to account_path(params[:id])
  end

  def check_in
    ce = ConversationItemEvent.create(lat: request.location.latitude, long: request.location.longitude, ip_address: request.location.ip, type: "check_in", conversation_item_id: params[:conversation_item_id], user_id: current_user.id)
    if ce
      flash[:success] = 'Successfully Checked In'
    else
      flash[:danger] = "Couldn't Checked In"
    end
    redirect_to account_path(params[:id])
  end

  def check_out
    ce = ConversationItemEvent.create(lat: request.location.latitude, long: request.location.longitude, ip_address: request.location.ip, type: "check_out", conversation_item_id: params[:conversation_item_id], user_id: current_user.id)
    if ce
        flash[:success] = 'Successfully Checked Out'
      else
        flash[:danger] = "Couldn't Checked Out"
      end
    redirect_to account_path(params[:id])
  end

  def jump_in
    c_id = @account.conversation.id
    items = @account.conversation.conversation_items
    items.each do |n|
      @meeting = n if n.id == params[:conversation_item_id].to_i
    end
    params[:conversation_item] ={}
    params[:conversation_item][:id] = params[:conversation_item_id]
    params[:conversation_item][:invitees] = @meeting.invitees+', '+"#{current_user.email}"
    if @meeting.update_attributes(request: :update, conversation_item: params[:conversation_item], conversation_id: c_id, reload: true)
      flash[:success] = 'successfully jumped!'
    else
      flash[:danger] = "Couldn't jumped!"
    end
    redirect_to account_path(params[:id])
  end

  def add_note
    c_id = Account.find(conversation_item_params[:account_id]).conversation.id
    if params[:scheduled_date].present? && params[:scheduled_time].present?
      params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
    end
    ci = ConversationItem.create(conversation_item: {title: conversation_item_params[:subject], body: conversation_item_params[:body], scheduled_at: params[:conversation_item][:scheduled_at]}, conversation_id: c_id, type: conversation_item_params[:type])
    if ci
      flash[:success] = 'Your note has been added to the conversation'
    else
      flash[:danger] = 'Oops! Unable to add note'
    end

    redirect_to account_path(conversation_item_params[:account_id])
  end

  def update_note
    conversation_id = @account.conversation.id
    if params[:conversation_item][:reminder].present?
      if params[:scheduled_date].present? && params[:scheduled_time].present?
        params[:conversation_item][:scheduled_at] = convert_datetime_to_utc(current_user.time_zone, params[:scheduled_date], params[:scheduled_time])
      end
    else
      params[:conversation_item][:scheduled_at] = nil
      params[:conversation_item][:reminder] = nil
    end

    note = @account.conversation.conversation_items
    note.each do |n|
      @conversation = n if n.id == params[:conversation_item][:id].to_i
    end
    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id)
      flash[:success] = 'Note successfully updated!'
    else
      flash[:danger] = 'Note not updated!'
    end
    redirect_to account_path(params[:id])
  end

  def delete_note
    note = @account.conversation.conversation_items
    note.each do |n|
      @conversation = n if n.id == params[:item_id].to_i
    end
    if @conversation.destroy
      flash[:success] = 'Note successfully deleted'
    else
      flash[:danger] = 'Oops! Unable to delete the note'
    end
    redirect_to account_path(params[:id])
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
            scheduled_at: params[:conversation_item][:scheduled_at]
          },
        conversation_id: c_id, type: "email")
    if ci
      flash[:success] = 'Your email has been successfully sent'
    else
      flash[:danger] = 'Oops! Looks like there was a problem sending your email'
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

    email = @account.conversation.conversation_items

    email.each do |n|
      @conversation = n if n.id == params[:conversation_item][:id].to_i
    end

    if @conversation.update_attributes(conversation_item: params[:conversation_item], conversation_id: conversation_id)
      flash[:success] = 'Email successfully updated!'
    else
      flash[:danger] = 'Email not updated!'
    end
    redirect_to account_path(params[:id])
  end

  def delete_email
    email = @account.conversation.conversation_items
    email.each do |n|
      @conversation = n if n.id == params[:item_id].to_i
    end
    if @conversation.destroy
      flash[:success] = 'Email successfully deleted'
    else
      flash[:danger] = 'Oops! Unable to delete the email'
    end
    redirect_to account_path(params[:id])
  end

  def share
    params[:account][:user_account_sharings_attributes] = params[:account][:user_account_sharings_attributes].values
    if @account.update_attributes(request: :update, account: shared_account_params)
      flash[:success] = 'Shared users updated successfully'
    else
      flash[:danger] = 'Oops! Unable updated the shared users'
    end
    redirect_to account_path(params[:id])
  end

  def search
    c_id = @account.conversation.id
    apiURL = APP_CONFIG['api_url'] + '//conversations/'+ "#{c_id}" + '/items?'
    apiFullUrl = apiURL +  "search[type_cont]=#{params[:search][:type_cont]}&starts_at_gteq=#{params[:search][:data_gteq]}&starts_at_lteq=#{params[:search][:date_lteq]}";
    headers = {}
    headers["Authorization"] = "Token token=\"#{@token}\",email=\"#{@email}\", app_key=\"#{@appKey}\""
    @conversation_items = HTTParty.get(apiFullUrl,headers: headers)
  end



  private


  def get_token
    #set gloal var for token to be used in model, hack for now
    $user_token = session[:token]
  end


  def account_params
    params.require(:account).permit(
      :name, :status_id, :assign_to, :shared_with, :about, :quick_facts, :avatar,
      addresses_attributes: [:id, :name, :street_address, :postcode, :city, :region, :country, :_destroy],
      contacts_attributes: [:id, :type, :name, :value, :_destroy]
    )
  end


  def conversation_item_params
    params.require(:conversation_item).permit(:account_id, :type, :reminder, :scheduled_at, :subject, :body, :email, :send_later, :title)
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


end
