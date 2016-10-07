class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Mobylette::RespondToMobileRequests
  force_ssl if Rails.env.production?
  # rescue_from Rack::Utils::ParameterTypeError, with: :render_bad_request

  protect_from_forgery with: :exception
  before_filter :get_tenant_by_subdomain #need to do before auth to get tenant
  before_filter :set_cache_headers
  before_filter :authentication
  before_filter :notification_info
  before_filter :clear_session_variable
  #before_filter :accounts_cache  # DIS001 disabled for now
  # around_filter :set_time_zone

  helper_method :current_user, :current_company, :get_api_values, :logged_in?, :superadmin_logged_in?, :notification_info, :company_settings_load
  helper_method :has_permission, :has_permissions, :has_page_permission, :has_page_permissions, :accounts_cache

  rescue_from ActiveResource::ForbiddenAccess do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    render_403
  end

  rescue_from ActiveResource::ResourceNotFound do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    render_404
  end

  rescue_from ActiveResource::ServerError do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    render_500
  end

  rescue_from ActiveResource::MissingPrefixParam do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    flash[:danger] = exception.message
    redirect_to root_url
  end

  rescue_from ActiveResource::ClientError do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    flash[:danger] = exception.message
    redirect_to root_url
  end

  rescue_from ActiveResource::UnauthorizedAccess do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    flash[:danger] = exception.message
    redirect_to root_url
  end

  rescue_from ActiveResource::ResourceInvalid do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    flash[:danger] = exception.message
    redirect_to root_url
  end

  rescue_from ActiveResource::ConnectionError do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    render_403
  end

  rescue_from ActiveResource::ResourceGone do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    flash[:danger] = exception.message
    redirect_to root_url
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rollbar.error(exception, use_exception_level_filters: true)
    flash[:danger] = exception.message
    redirect_to root_url
  end

  def raise_bad_request
    redirect_to root_url, notice: 'page not found!'
    return
  end

  def get_news
    news_data = Hash[]
    apiFullUrl = RequestStore.store[:api_url] + '/company/settings/preferences'
    curlRes = `curl -X GET -H "Authorization: Token token="#{session[:token]}", email="#{current_user.email}", app_key="#{APP_CONFIG['api_app_key']}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{apiFullUrl}"`
    company_settings = JSON.parse(curlRes)
    company_settings = company_settings['company']['settings']['preferences']
    company_settings.each { |setting, value|
    if setting.include? 'news'
      if (value.present?)
        news_data[setting.to_sym] = value
      end
    end
    }
    @news_data = news_data.delete_if { |key, value| value.blank? }
  end

  # def render_bad_request
  #   redirect_to root_url, notice: 'page not found!'
  # end

  private

  def render_403
    render file: "#{Rails.root}/public/403.html", status: 403
  end

  def render_404
    render file: "#{Rails.root}/public/404.html", status: 404
  end

  def render_500
    if session[:user_id].eql?('superadmin')
      render file: "#{Rails.root}/public/500_super_admin.html", status: 500
    else
      render file: "#{Rails.root}/public/500.html", status: 500
    end
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end

  # def set_time_zone
  #   old_time_zone = Time.zone
  #   Time.zone = browser_timezone if browser_timezone.present?
  #   yield
  # ensure
  #   Time.zone = old_time_zone
  # end

  # def browser_timezone
  #   cookies['browser.timezone']
  # end

  def get_tenant_by_subdomain
    if request.subdomains.any?
      # RequestStore.store[:tenant] = "acme"
      RequestStore.store[:tenant] = request.subdomain
    else
      RequestStore.store[:tenant] = "acme" #sandbox
    end
    # move into a service
    api_host = "#{RequestStore.store[:tenant]}-api.code10.ca"
    RequestStore.store[:api_url] = "https://#{api_host}/api/v1"
    OrchardApiModel.site = RequestStore.store[:api_url]
    # OrchardApiModel.site.host = api_host
  end

  def authentication
    store_location
    if current_user.blank?
      if session[:user_id].present? && superadmin_logged_in?
        set_superadmin
      else
        if session[:token].nil?
          flash[:danger] = 'Your session has expired. Please log in again.'  # Log in error message
          redirect_to root_path
        else
          set_current_user
        end
      end
    end
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if (request.path != "/" &&
        request.path != "/login/destroy" &&
        request.path != "/login" &&
        controller_name != "errors" &&
        action_name != "routing" &&
        controller_name == "notifications" &&
        action_name == "show" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def clear_session_variable
    if controller_name != "accounts"
      session.delete(:search)
      session.delete(:page)
    end
  end


  def set_current_user
    RequestStore.store[:user_token] = session[:token]
    #Move into a service
    OrchardApiModel.headers['Authorization'] = "Token token=\"#{RequestStore.store[:user_token]}\", app_key=\"#{APP_CONFIG['api_app_key']}\""

    @current_user ||= User.find(session[:user_id], reload: true)
    @current_user.id = session[:user_id]
    Time.zone = @current_user.time_zone
  end

  def set_superadmin
    RequestStore.store[:user_token] = session[:token]
    @superadmin_email = APP_CONFIG['superadmin_email']
  end

  def superadmin_logged_in?
    return true if session[:user_id].eql?('superadmin')
    false
  end

  def current_user
    @current_user
  end

  def logged_in?
    current_user != nil
  end

  def convert_datetime_to_utc(timezone, date, time="00:00:00")
    @parsed_datetime = Chronic.parse("#{date} at #{time}").strftime('%Y-%m-%d %H:%M:%S')
    begin
      @timezone_short = TZInfo::Timezone.get("#{timezone}").period_for_utc(Time.now).abbreviation.to_s
    rescue
      @timezone_short = timezone
    end

    @utc_datetime = (DateTime.parse "#{@parsed_datetime} #{@timezone_short}").utc.strftime("%Y-%m-%d %H:%M:%S %z")
  end

  # Check permission by single credential criterion
  def has_permission(subject_class, action, action_scope="")
    #example usage: has_permission("all", "manage")
    #               has_permission("User", "read", "company")
    #               has_permission("Account", ["read", "update", "manage"])
    #               has_permission("Account", ["read", "update", "manage"], ["company", "entity"])
    #
    #subject_class: string
    #action:        string or an array
    #action_scope:  string or be left empty

    #check that subject_class and action are not empty
    unless subject_class.empty? && action.empty?

      roles = Role.all
      user_roles = @current_user.roles

      #match user's roles with the roles list and extract all the permissions into a hash
      current_user_permissions = Array.new
      user_roles.each do | current_user_role |
        roles.each do | current_role |

          if current_user_role.id == current_role.id
            current_role.permissions.each do | current_permission |
              current_user_permissions.push(current_permission)
            end
          end
        end
      end

      # check and match against the subject_class, action and action_scope between current_user_permissions
      # if match found, return true
      unless current_user_permissions.empty?
        current_user_permissions.each do |current_user_permission|
          # check if subject_class matches
          if subject_class == current_user_permission.subject_class
            action_matched = false
            action_scope_matched = false

            #check for matching action
            if action.is_a?(Array)
              action_matched = action.include? current_user_permission.action
            else
              action_matched = (action == current_user_permission.action)
            end

            # addition check, action_scope if provided.  And if not present, then return true.
            unless action_scope.present?
              action_scope_matched = true
            else
              if action_scope.is_a?(Array)
                action_scope_matched = action_scope.include? current_user_permission.action_scope
              else
                action_scope_matched = (action_scope == current_user_permission.action_scope)
              end
            end

            return true if action_matched == true && action_scope_matched == true
          end

        end
      end

    end #unless subject_class.empty? && action.empty?

    false
  end

  # Check permission by multiple credential criteria
  def has_permissions(allowed_permissions)
    #example usage: has_permissions({ "User"=>{"actions"=>["read","update","manage"], "action_scope"=>["company"]}, "all"=>{"actions"=>["read","update","manage"]} })
    #allowed_permissions (hash) example: allowed_permissions = "User"=>{"actions"=>["read","update","manage"], "action_scope"=>["company"]}, "all"=>{"actions"=>["read","update","manage"]}
    #Note: Hash "actions" and "action_scope" can be string or an array.  And "action_scope" is an optional parameter.

    #check allowed_permissions is not empty
    unless allowed_permissions.empty?
      allowed_permissions.each do | permission_key, allowed_permission |
      subject_class = permission_key
      action = allowed_permission["actions"]
      action_scope = allowed_permission["action_scope"]

      return true if has_permission(subject_class, action, action_scope) == true
      end
    end #unless allowed_permissions.empty?

    false
  end

  def has_page_permission(subject_class, action, action_scope="", message="", redirect_path="")
    return true if has_permission(subject_class, action, action_scope)

    unless message.blank?
      flash[:danger] = message
    end

    if redirect_path.blank?
      #redirect_to dashboard_path
      #render :file => "#{Rails.root}/public/404.html",  :status => 404, :layout => false
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    else
      redirect_to redirect_path
    end
  end

  def has_page_permissions(allowed_permissions, message="", redirect_path="")
    #example usage: has_page_permissions({ "User"=>{"actions"=>["read","update","manage"], "action_scope"=>["company"]}, "all"=>{"actions"=>["read","update"]} }, "Ok, I'll send you to Company page.", company_path)

    return true if has_permissions(allowed_permissions)

    unless message.blank?
      flash[:danger] = message
    end

    if redirect_path.blank?
      # redirect_to dashboard_path
      # render :file => "#{Rails.root}/public/404.html",  :status => 404, :layout => false
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    else
      redirect_to redirect_path
    end
  end

  def notification_info
    @read_items = Array[]
    @unread_items = Array[]
    @menu_bar_items = {}

    # check if we have set the current user before getting any notifications
    if current_user.present?
      @user_preference = user_preferences_load
      preference_limit = @user_preference['notification_display_limit']
      search = Hash.new
      current_date = Date.current.in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
      search[:created_at_lteq] = convert_datetime_to_utc(current_user.time_zone, current_date, "23:59:59")
      if preference_limit.present?
        if preference_limit == 'one_day'
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, current_date, "00:00:00")
        elsif preference_limit == 'two_days'
          end_date = (Date.current - 1.day).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
        elsif preference_limit == 'three_days'
          end_date = (Date.current - 2.day).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
        elsif preference_limit == 'one_week'
          end_date = (Date.current - 1.week).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
        elsif preference_limit == 'two_weeks'
          end_date = (Date.current - 2.week).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
        elsif preference_limit == 'three_weeks'
          end_date = (Date.current - 3.week).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
        elsif preference_limit == 'one_month'
          end_date = (Date.current - 1.month).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
          search[:created_at_gteq] = convert_datetime_to_utc(current_user.time_zone, end_date, "00:00:00")
        end
        @notifications = Notification.all(params: {search: search})
      else
        @notifications = Notification.all
      end
      user_ids = []
      user_ids.push(current_user.id)

      # Retrieve notifications and sort read / unread
      if @notifications.present?
        @notifications.each do |notification|
          if notification.read_at.present?
            @read_items.push(notification)
          else
            @unread_items.push(notification)
          end
        end
      end

      # sort the read items just in case and put the newest at the top
      if (@unread_items.count > 1)
        @unread_items = @unread_items.sort_by { |k| k.created_at }.reverse
      end
    end
  end

  def accounts_cache
    accounts_cache_info = session[:accounts_cache]

    if accounts_cache_info.nil?
      accounts_cache_info = accounts_cache_refresh
    else
      accounts_cache_info = JSON.parse(accounts_cache_info)
      if (DateTime.parse(accounts_cache_info["last_update"]).to_i + 15.minutes.to_i) < DateTime.now.to_i
        accounts_cache_info = accounts_cache_refresh
      end
    end

    accounts_cache_info
  end

  def accounts_cache_refresh(id=false)
    accounts = Account.all
    # temporary fix to get all the accounts
    if accounts.meta["total_pages"] > 1
      accounts = Account.all(params: { per_page: accounts.meta["total_entries"] })
    end

    #Account.find(params[:id])
    accounts_cache_info = {}
    accounts_cache_info["last_update"] = DateTime.now

    accounts_cache_info["accounts"] = {}
    accounts_cache_info["accounts"] = accounts.collect { |a| [a.id, a.name] }.to_h

    session[:accounts_cache] = accounts_cache_info.to_json
    accounts_cache_info
  end

  def current_company
    @current_company ||= Company.find(uid: RequestStore.store[:tenant])
  end

  def user_preference_details
    @apiFullUrl = RequestStore.store[:api_url] + "/users/#{current_user.id}/settings/preferences"
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
    curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{@apiFullUrl}"`
    user_preference = JSON.parse(curlRes)
    user_preference = user_preference['user']['settings']['preferences']
    user_preference.shift
    @user_preference = user_preference
  end

  def user_preferences_load(refresh=false)
    user_preferences_info = session[:user_preferences]

    if user_preferences_info.nil? || refresh == true
      apiFullUrl = RequestStore.store[:api_url] + "/users/#{current_user.id}/settings/preferences"
      email = current_user.email
      appKey = APP_CONFIG['api_app_key']
      token = session[:token]
      curlRes = `curl -X GET -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{apiFullUrl}"`

      user_preferences = JSON.parse(curlRes)
      user_preferences = user_preferences['user']['settings']['preferences']
      user_preferences.shift
      session[:user_preferences] = user_preferences.to_json
    else
      user_preferences = JSON.parse(user_preferences_info)
    end

    user_preferences
  end

#   def check_request
#     unless request.format.symbol.present?
#       render text: 'page loaded'
#     end
#   end


  # Note: try to replace the bottom methods,  get_automatic_logout_time and get_account_display_setting
  def company_settings_load(refresh=false)
    company_settings_info = session[:company_settings]

    unless company_settings_info.nil?
      company_settings_current = JSON.parse(company_settings_info)
      if company_settings_current['last_update'].nil? || (DateTime.parse(company_settings_current['last_update']).to_i + 15.minutes.to_i) < DateTime.now.to_i
        refresh = true
      end
    end

    if company_settings_info.nil? || refresh
      company_settings = {}
      email = current_user.email
      appKey = APP_CONFIG['api_app_key']
      token = session[:token]

      apiFullUrl_authentication = RequestStore.store[:api_url] + '/company/settings/authentication'
      curlRes_authentication = `curl -X GET -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{apiFullUrl_authentication}"`
      company_authentication = JSON.parse(curlRes_authentication)
      company_settings['authentication'] = company_authentication['company']['settings']['authentication']

      apiFullUrl_preferences = RequestStore.store[:api_url] + '/company/settings/preferences'
      curlRes_preferences = `curl -X GET -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{apiFullUrl_preferences}"`
      company_preferences = JSON.parse(curlRes_preferences)
      company_settings['preferences'] = company_preferences['company']['settings']['preferences']

      unless company_settings.nil?
        company_settings['last_update'] = DateTime.now
      end

      session[:company_settings] = company_settings.to_json
    else
      company_settings = JSON.parse(company_settings_info)
    end

    company_settings
  end


  #def get_automatic_logout_time
  #  get_api_values
  #  apiFullUrl = RequestStore.store[:api_url] + "/company/settings/authentication"
  #  authentication = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{apiFullUrl}"`
  #  authentication = JSON.parse(authentication)
  #  @session_expire_time = authentication['company']['settings']['authentication']['automatic_logout']
  #end

  def get_account_display_setting
    preferences = company_settings_load['preferences']

    @account_per_page = preferences['account_per_page']
    @account_by_status = preferences['accounts_by_status']
    @enable_import = preferences['enable_import'] || "unknown"
    @enable_export = preferences['enable_export'] || "unknown"
    @enable_expected_sales = preferences['enable_expected_sales_attributes'] || "unknown"
    @daylight_setting = preferences['enable_dst']
    @enable_checkin_checkout = preferences['enable_checkin_checkout'] || "unknown"
    @enable_regular_visits_sort = preferences['enable_regular_visits_sort'] || "unknown"
  end

  def application_settings
    get_api_values
    apiFullUrl = RequestStore.store[:api_url] + '/company/settings/private'
    application_setting = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -H "Cache-Control: no-cache" "#{apiFullUrl}"`
    application_setting = JSON.parse(application_setting)

    @account_properties = application_setting['company']['settings']['private']['account_properties']
    @account_properties = JSON.parse(@account_properties) unless (@account_properties.nil? || @account_properties.is_a?(Hash))
    @assets =  application_setting['company']['settings']['private']['asset_properties']
    @assets = JSON.parse(@assets) unless (@assets.nil? || @assets.is_a?(Hash))
    @leads = application_setting['company']['settings']['private']['leads_enabled']
    @assets_management = application_setting['company']['settings']['private']['asset_management']
  end

  def get_api_values
    @email = current_user.blank? ? set_superadmin : current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
