class SettingsController < ApplicationController
  load_and_authorize_resource class: "SettingsController"

	def index
	end

	def company_level_setting
     redirect_to dashboard_path
	end

end
