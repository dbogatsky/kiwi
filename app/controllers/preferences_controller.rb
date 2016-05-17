class PreferencesController < ApplicationController
  before_action :get_api_values

  def show
    curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{@apiFullUrl}"`
    # news_data = JSON.parse(curlRes)
    # news_data = news_data['company']['settings']['preferences']
    # news_data.shift
    # @news_data = news_data.delete_if { |key, value| value.blank? }
  end

  def update
    curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"default_calendar_view": "#{params[:preference][:default_calendar_view]}", "preview_conversation_timeline": "#{params[:preference][:preview_conversation_timeline]}", "received_notification_by": "#{params[:preference][:received_notification_by]}", "notification_display_limit": "#{params[:preference][:notification_display_limit]}"}}' '#{@apiFullUrl}'`
    flash[:success] = 'Your preference has been successfully updated!'
    redirect_to preference_path
  end


  private

  def get_api_values
    @apiFullUrl = RequestStore.store[:api_url] + "/users/#{current_user.id}/settings/preferences"
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
