class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :get_tenant_by_subdomain #need to do before auth to get tenant
  before_filter :set_cache_headers
  before_filter :authentication
#   before_filter :check_request
  around_filter :set_time_zone

  helper_method :current_user, :logged_in?, :superadmin_logged_in?
  helper_method :has_permission, :has_permissions, :has_page_permission, :has_page_permissions

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = browser_timezone if browser_timezone.present?
    yield
  ensure
    Time.zone = old_time_zone
  end

  def browser_timezone
    cookies['browser.timezone']
  end

  def get_tenant_by_subdomain
    if request.subdomains.any?
      # RequestStore.store[:tenant] = "acme"
      RequestStore.store[:tenant] = request.subdomain
    else
      RequestStore.store[:tenant] = "acme" #sandbox
    end
    #move into a service
    RequestStore.store[:api_url] = "https://#{RequestStore.store[:tenant]}-api.code10.ca/api/v1"
    OrchardApiModel.site = RequestStore.store[:api_url]
  end


  def authentication
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


  def set_current_user
    RequestStore.store[:user_token] = session[:token]
    #Move into a service
    OrchardApiModel.headers['Authorization'] = "Token token=\"#{RequestStore.store[:user_token]}\", app_key=\"#{APP_CONFIG['api_app_key']}\""

    @current_user = User.find(session[:user_id], reload: true)
    @current_user.id = session[:user_id]
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

      #check and match against the subject_class, action and action_scope between current_user_permissions
      #if match found, return true
      unless current_user_permissions.empty?
        current_user_permissions.each do | current_user_permission |

          #check if subject_class matches
          if subject_class == current_user_permission.subject_class
            action_matched = false
            action_scope_matched = false

            #check for matching action
            if action.is_a?(Array)
              action_matched = action.include? current_user_permission.action
            else
              action_matched = (action == current_user_permission.action)
            end

            #addition check, action_scope if provided.  And if not present, then return true.
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
      #redirect_to dashboard_path
      #render :file => "#{Rails.root}/public/404.html",  :status => 404, :layout => false
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    else
      redirect_to redirect_path
    end
  end

#   def check_request
#     unless request.format.symbol.present?
#       render text: 'page loaded'
#     end
#   end
#
end
