class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, :to => :manage_permission
    alias_action :create, :update, :to => :update_shared_accounts
    alias_action :create, :update, :destroy, :to => :manage_shared_accounts

    user ||= User.new # guest user (not logged in)
    roles = Role.all # (:reload => true) #(uid: RequestStore.store[:tenant], :reload => true)
    abilities_debug = []
    admin_user = false

    # match user's roles with the roles list
    user.roles.each do |current_user_role|
      roles.each do |current_role|

        # match found, extract all the permissions and define abilities
        if current_user_role.id == current_role.id
          current_role.permissions.each do |permission|

            # define abilities
            if permission.subject_class == 'all' && permission.action == 'manage'
              admin_user = true
              can :manage, :all
              abilities_debug.push('can :manage, :all')

              # can permission.action.to_sym, permission.subject_class.to_sym
              # abilities_debug.push("can :" + permission.action + ", :" + permission.subject_class)
            else

              # defining ability with subject class as just the class name
              if permission.action == 'manage' && current_user_role.name != 'Entity Admin'
                begin
                  can :manage_permission, permission.subject_class.constantize
                  abilities_debug.push('can :manage_permission, ' + permission.subject_class)
                rescue NameError
                  #raise("#{permission.subject_class} Permission Not Handled")
                  abilities_debug.push('NOT HANDLED NameError : can :manage_permission, ' + permission.subject_class)
                  next
                end
              else
                begin
                  can permission.action.to_sym, permission.subject_class.constantize
                  abilities_debug.push('can :' + permission.action + ', ' + permission.subject_class)
                rescue NameError
                  #raise("#{permission.subject_class} Permission Not Handled")
                  abilities_debug.push('NOT HANDLED NameError : can :manage_permission, ' + permission.subject_class)
                  next
                end
              end

              # defining ability with subject class being constantized (tries to find a declared constant with the name specified in the string)
              # can permission.action.to_sym, permission.subject_class.constantize
            end
          end

          unless admin_user

            # Special Permissions for Enity Admin
            if current_user_role.name == 'Entity Admin'
              # Permission for showing the schedule filter textbox (for Entity Admin)
              can :schedule_filter, Account
              abilities_debug.push('can :schedule_filter, Account')

              # Permission for Uploading and creating folders in the media page
              can :media_management, Medium
              abilities_debug.push('can :media_upload, Medium')

              # Permission for Uploading and creating folders in the media page
              can :user_management, User
              abilities_debug.push('can :user_management, User')
            end

            # Permission to definite managed shared accounts
            can :manage_shared_accounts, Account do |account|
              abilities_debug.push('can :manage_shared_accounts, Account') if account.assigned_to.id == user.id
              account.assigned_to.id == user.id
            end

            # Permission to definite update shared accounts
            can :update_shared_accounts, Account do |account|
              shared_user_update = []
              account.user_account_sharings.each { |u| shared_user_update << u.user if u.permission == 'update' }

              abilities_debug.push("can :update_shared_accounts, Account | NOTE: Account ID[#{account.id}]") if shared_user_update.include? user.id
              shared_user_update.include? user.id
            end

          end
        end
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
