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

  def expected_sales_select_options
    return [['Disable', 'disable'],['Enable','enable']]
  end

  def enable_regular_visits_sort_options
    return [['Disable', 'disable'],['Enable','enable']]
  end
end
