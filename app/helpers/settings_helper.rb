module SettingsHelper
	def perview_timeline_select_options
    return [['1 day',1], ['3 days', 3], ['1 week', 7], ['2 weeks', 14], ['1 month', 31]]
  end

  def automatic_logout_select_options
    return [['1 hour',1], ['2 hours', 2], ['6 hours', 6], ['12 hours', 12], ['1 day', 24], ['3 days', 72], ['5 days', 120]]
  end

  def account_per_page_select_options
    return [['10 accounts',10], ['20 accounts', 20], ['30 accounts', 30], ['40 accounts', 40], ['50 accounts', 50]]
  end

  def account_by_account_status_select_options
    return AccountStatus.all(uid: RequestStore.store[:tenant]).collect{ |a| ["#{a.name}", a.id] }
  end

  def enable_import_export_select_options
    return [['None','none'], ['User', 'user'], ['Entity Admin', 'entity_admin'], ['All', 'all']]
  end

  def enable_disable_options
    return [['Disable', 'disable'],['Enable','enable']]
  end

  def approval_for_account_transfer_options
    return [['By Admins and Entity Admins Only', true],['None', false]]
  end

  def gps_tracking_interval_options
    return [['Off', -1], ['5 secs', 5], ['10 secs', 10], ['30 secs', 30], ['1 min', 60], ['5 mins', 300], ['10 mins', 600], ['15 mins', 900], ['30 mins', 1800], ['45 mins', 2700], ['1 hour', 3600]]
  end

  def general_timeline_select_options
    return [['1 day',1], ['2 days', 2], ['3 days', 3], ['4 days', 4], ['5 days', 5], ['6 days', 6], ['1 week', 7], ['2 weeks', 14], ['3 weeks', 21], ['4 weeks', 28]]
  end

end

