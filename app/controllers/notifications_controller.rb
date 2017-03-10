class NotificationsController < ApplicationController
  def index
    result = AccountTransfer.pending_approval
    pending_account_transfers = JSON.parse(result.body)
    @pending_account_notifications = pending_account_transfers["account_transfers"]
    @pending_account_notifications.each do |pending_account|
      account_id = pending_account["account"]["id"]
      account_transfer_id = pending_account["id"]
    end
  end

  def update
    begin
      @notification = Notification.find(params[:id])
      @notification.update_attributes(read_at: Time.now)
      notification_info
      @result = true
    rescue
      @result = false
    end
  end

  def show
    session[:previous_url] = nil
    flash.clear
    notification = Notification.find(params[:id]) rescue nil
    flash[:danger] = "Sorry, we're unable to find your notification" unless notification
    render :index
  end

  def conversation_detail
    if params[:notification_read] == 'false'
      @notification = Notification.find(params[:notification_id])
      @notification.update_attributes(read_at: Time.now)
      notification_info
    end

    user_ids = Array[]
    user_ids.push(current_user.id)

    @notification_type = params[:notification_type]
    case params[:notification_type]
      when 'reminder'
        search = Hash[]
        search[:id_eq] = params[:conversation_id]
        search[:type_eq] = 'ConversationItems::Reminder'

        @item = ConversationItemSearch.all(params: { user_ids: user_ids, search: search })
      when 'meeting_reminder'
        search = Hash[]
        search[:id_eq] = params[:conversation_id]
        search[:type_eq] = 'ConversationItems::Meeting'

        @item = ConversationItemSearch.all(params: { user_ids: user_ids, search: search })
      when 'account_status_change'
        begin
          @item = Account.find(params[:conversation_id])
        rescue ActiveResource::ResourceNotFound
          @item = nil
        end
    end
    @notification = { id: params[:item_id], type: params[:notification_type] }
    render template: 'notifications/_conversation_details', layout: false
  end
end
