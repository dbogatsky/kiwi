class Admin::SettingsController < Admin::AdminController
	include HTTParty

  before_action :get_settings, only: [:index, :delete_property, :add_and_update_property]

  def index
    @company ||= BoCompany.find(params[:company_id], reload: true)
  end

  def update_settings
    get_api_values
    apiFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/private"
    curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"asset_management": "#{params[:asset_management]}"}}' '#{apiFullUrl}'`
    flash[:success] = 'Your setting has been successfully updated!'
    redirect_to admin_company_settings_path(params[:company_id])
  end


  def add_and_update_property
    new_property = {}
    new_property[params[:property_id]] = {}
    new_property[params[:property_id]] = {'label'=>params[:label], 'required'=>params[:required], 'format'=>params[:format], 'values'=>params[:values]}
    @account_properties.merge!(new_property)
    query = {}
    query['settings'] = {}
    query['settings']['account_properties'] = @account_properties
    HTTParty.put(@boApiFullUrl, query: query, headers: @headers)
    flash[:success] = 'Account property has been successfully saved!'
    redirect_to admin_company_settings_path(params[:company_id])
  end

  def delete_property
    @account_properties.except!(params[:property_id])
    query = {}
    query['settings'] = {}
    query['settings']['account_properties'] = @account_properties
    HTTParty.put(@boApiFullUrl,:query => query,:headers => @headers)
    redirect_to admin_company_settings_path(params[:company_id])
  end

  private

    def get_settings
      get_api_values
      headers = {}
      headers["Authorization"] = "Token token=\"#{@token}\",email=\"#{@email}\", app_key=\"#{@appKey}\""
      @headers = headers
      @boApiFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/private"
      application_setting = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{@boApiFullUrl}"`
      application_setting = JSON.parse(application_setting)
      @account_properties = application_setting['company']['settings']['private']['account_properties']
      @account_properties = JSON.parse(@account_properties) unless (@account_properties.nil? || @account_properties.is_a?(Hash))
      @leads = application_setting['company']['settings']['private']['leads_enabled']
      @assets_management = application_setting['company']['settings']['private']['asset_management']
    end
end