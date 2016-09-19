class Admin::SettingsController < Admin::AdminController
	before_action :find_company, only: [:index]

  def index
    get_api_values
    boApiFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/private"
    application_setting = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{boApiFullUrl}"`
    application_setting = JSON.parse(application_setting)
    @account_properties = application_setting['company']['settings']['private']['account_properties']
    @account_properties = JSON.parse(@account_properties) unless (@account_properties.nil? || @account_properties.is_a?(Hash))
    @leads = application_setting['company']['settings']['private']['leads_enabled']
    @assets_management = application_setting['company']['settings']['private']['asset_management']
  end

  def update_settings
    get_api_values
    @apiFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/private"
    authentication_curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"asset_management": "#{params[:asset_management]}"}}' '#{@apiFullUrl}'`
    flash[:success] = 'Your setting has been successfully updated!'
    redirect_to admin_company_settings_path(params[:company_id])
  end


  def add_property
    get_api_values
    @apiFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/private"
    authentication_curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"account_properties": {"#{params[:property_id]}": {"label": "#{params[:label]}", "required": "#{params[:required]}", "format": "#{params[:format]}", "value": "#{params[:value]}"}}}}' '#{@apiFullUrl}'`
    flash[:success] = 'Account property has been successfully added!'
    redirect_to admin_company_settings_path(params[:company_id])
  end


  private
    def find_company
      @company = BoCompany.find(params[:company_id], reload: true)
    end
end