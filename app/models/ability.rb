class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)
    roles = Role.all
    abilities_debug = Array.new

    # match user's roles with the roles list
    user.roles.each do | current_user_role |
      roles.each do | current_role |

        # match found, extract all the permissions and define abilities
        if current_user_role.id == current_role.id
          current_role.permissions.each do | permission |

            #define abilities
            if permission.subject_class == 'all' && permission.action == 'manage'
              can :manage, :all
              # can permission.action.to_sym, permission.subject_class.to_sym

              abilities_debug.push("can :manage, :all")
              #abilities_debug.push("can :" + permission.action + ", :" + permission.subject_class)
            else 
              # defining ability with subject class as just the class name
              can permission.action.to_sym, permission.subject_class
              abilities_debug.push("can :" + permission.action + ", :" + permission.subject_class)

              # defining ability with subject class being constantized (tries to find a declared constant with the name specified in the string)
              #can permission.action.to_sym, permission.subject_class.constantize
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
