class PreferencesController < ApplicationController
  before_action :get_api_values

  def show
    @user_preference = user_preferences_load
    @user_notification_setting = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{@apiUrl_for_notification}"`
    @user_notification_setting = JSON.parse(@user_notification_setting)
    @user_notification_setting = @user_notification_setting['user']['settings']['notifications']

    @integrations_settings = integrations_settings
  end

  def update
    curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"show_accounts_per_page": "#{params[:preference][:show_accounts_per_page]}", "default_calendar_view": "#{params[:preference][:default_calendar_view]}", "preview_conversation_timeline": "#{params[:preference][:preview_conversation_timeline]}", "received_notification_by": "#{params[:preference][:received_notification_by]}", "notification_display_limit": "#{params[:preference][:notification_display_limit]}"}}' '#{@apiFullUrl}'`

    if params[:notifications].present?
      params[:notifications][:email] = params[:notifications][:email].blank? ? false : true
      params[:notifications][:sms] = params[:notifications][:sms].blank? ? false : true
      curlResForNotification = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"email": "#{params[:notifications][:email]}", "sms": "#{params[:notifications][:sms]}"}}' '#{@apiUrl_for_notification}'`
    else
     curlResForNotification = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"email": "false", "sms": "false"}}' '#{@apiUrl_for_notification}'`
    end

    flash[:success] = 'Your preference has been successfully updated!'
    user_preferences_load(true)
    redirect_to preference_path
  end


  private

  def get_api_values
    @apiFullUrl = RequestStore.store[:api_url] + "/users/#{current_user.id}/settings/preferences"
    @apiUrl_for_notification = RequestStore.store[:api_url] + "/users/#{current_user.id}/settings/notifications"
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
