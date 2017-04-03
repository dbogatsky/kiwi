class SettingsController < ApplicationController
  load_and_authorize_resource class: "SettingsController"

  def index
    @company_settings = company_settings_load(true)
    get_account_display_setting
  end

  def company_level_setting
    get_api_values

    params["accounts_by_status"] = "[]" if params["accounts_by_status"].nil?

    @apiFullUrl_authentication = RequestStore.store[:api_url] + "/company/settings/authentication"

    @apiFullUrl_preferences =  RequestStore.store[:api_url] + '/company/settings/preferences'

    authentication_curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"automatic_logout": "#{params[:automatic_logout]}"}}' '#{@apiFullUrl_authentication}'`

    preferences_curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"account_per_page": "#{params[:account_per_page]}", "accounts_by_status": #{params[:accounts_by_status]}, "enable_import": "#{params[:enable_import]}", "enable_dst": "#{params[:enable_dst]}", "enable_export": "#{params[:enable_export]}", "enable_expected_sales_attributes": "#{params[:expected_sales_attribute]}", "enable_checkin_checkout": "#{params[:enable_checkin_checkout]}", "enable_timezone_detect": "#{params[:enable_timezone_detect]}", "enable_regular_visits_sort": "#{params[:enable_regular_visits_sort]}", "search_all_accounts": "#{params[:search_all_accounts]}", "needs_approval_for_account_transfer": #{params[:approval_for_account_transfer]} }}' '#{@apiFullUrl_preferences}'`
    flash[:success] = 'Your setting has been successfully updated!'
    redirect_to settings_path
  end
end