class Admin::SettingsController < Admin::AdminController
	include HTTParty

  before_action :get_settings, only: [:index, :delete_property, :add_and_update_property, :add_and_update_asset, :delete_asset]

  def index
    @company ||= BoCompany.find(params[:company_id], reload: true)
  end

  def update_settings
    get_api_values
    apiFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/private"
    curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"asset_management": "#{params[:asset_management]}"}}' '#{apiFullUrl}'`

    boApiIntegrationFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/integrations"
    office365 = params[:office365_integration].to_s == 'on' ? 'true' : 'false'
    curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"settings":{"office365": "#{office365}"}}' '#{boApiIntegrationFullUrl}'`

    flash[:success] = 'Your setting has been successfully updated!'
    redirect_to admin_company_settings_path(params[:company_id])
  end


  def add_and_update_property
    new_property = {}
    new_property[params[:property_id]] = {}
    new_property[params[:property_id]] = {'label'=>params[:label], 'required'=>params[:required], 'format'=>params[:format], 'values'=>params[:values]}
    if @account_properties.present?
      @account_properties = @account_properties.merge!(new_property)
    else
      @account_properties = new_property
    end
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
    flash[:success] = 'Property has been successfully deleted!'
    redirect_to admin_company_settings_path(params[:company_id])
  end

  def add_and_update_asset
    if (params[:format] == 'enum' || params[:format] == 'select') && params[:values].present?
      params[:values] =  params[:values].gsub("\"",'')
      new_value_arr = []
      new_value_hash = {}
      params[:values] = params[:values].gsub('{','')
      params[:values] = params[:values].gsub('}','')
      params[:values] = params[:values].split(',')
      params[:values].each do |n|
        new_value_arr << n.split(':') if n.include?':'
        new_value_arr << n.split('=>') if n.include?'=>'
      end
      new_value_arr.each do |n|
         n = n.collect(&:squish)
         new_value_hash[n[0]] = n[1]
      end
      params[:values] = new_value_hash
    end
    new_asset = {}
    new_asset[params[:property_id]] = {}
    new_asset[params[:property_id]] = {'label'=>params[:label], 'required'=>params[:required], 'format'=>params[:format], 'values'=>params[:values]}
    if @assets.present?
      @assets = @assets.merge!(new_asset)
    else
      @assets = new_asset
    end
    query = {}
    query['settings'] = {}
    query['settings']['asset_properties'] = @assets
    HTTParty.put(@boApiFullUrl, query: query, headers: @headers)
    flash[:success] = 'Asset has been successfully saved!'
    redirect_to admin_company_settings_path(params[:company_id])
  end

  def delete_asset
    @assets.except!(params[:asset_id])
    query = {}
    query['settings'] = {}
    query['settings']['asset_properties'] = @assets.blank? ? nil : @assets
    HTTParty.put(@boApiFullUrl,:query => query,:headers => @headers)
    flash[:success] = 'Asset has been successfully deleted!'
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
      @assets =  application_setting['company']['settings']['private']['asset_properties']
      @assets = JSON.parse(@assets) unless (@assets.blank? || @assets.is_a?(Hash))
      @leads = application_setting['company']['settings']['private']['leads_enabled']
      @assets_management = application_setting['company']['settings']['private']['asset_management']

      @boApiIntegrationFullUrl = ENV.fetch("ORCHARD_BO_API_HOST") + "/companies/#{params[:company_id]}/settings/integrations"
      application_integration_setting = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{@boApiIntegrationFullUrl}"`
      application_integration_setting = JSON.parse(application_integration_setting)
      @office365_integration = application_integration_setting['company']['settings']['integrations']['office365'].to_s == 'true' ? 'on' : 'off'

    end
end