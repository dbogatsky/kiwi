module Admin::CompaniesHelper

  def assets_management_select_options
    return [['Off','off'],['On', 'on']]
  end

  def office365_integration_select_options
    return [['On', 'on'],['Off','off']]
  end

  def googlemap_autocomplete_select_options
    return [['On', 'on'],['Off','off']]
  end

  def gps_tracking_select_options
    return [['On', 'on'],['Off','off']]
  end

end
