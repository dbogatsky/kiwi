class Admin::AdminController < ApplicationController
  layout 'admin/application'
  before_action :authenticate_superadmin!

  protected
    def authenticate_superadmin!
      unless superadmin_logged_in?
        flash[:danger] = 'Unauthorized Access!'
        return redirect_to root_url
      end
    end

    def set_tenant_subdomain(subdomain)
      RequestStore.store[:tenant] = subdomain

      # move into a service
      api_host = "acme-api.code10.ca"
      # api_host = "#{RequestStore.store[:tenant]}-api.code10.ca"
      RequestStore.store[:api_url] = "https://#{api_host}/api/v1"
      OrchardApiModel.site = RequestStore.store[:api_url]
      # OrchardApiModel.site.host = api_host
    end
end