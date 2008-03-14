# AuthorizedSystem
module AuthorizedSystem

  # Policy: a simple named policy made up of resource rules. each rule
  # specifies a resource and the actions allowed on it. a special :system
  # resource is used to hold general system wide actions that do not apply
  # to a specific resource type.
  class Policy
    cattr_reader :name
    cattr_reader :resource_rules

    def initialize(name)
      @@name = name
      @@resource_rules = {}

      # action abstractions
      @@coalesced_actions = {
        :view     => [:read, :show, :list],
        :edit     => [:change, :add, :update],
        :comment  => [:vote, :star],
        :delete   => [:remove]
      }

      # TODO: cross-check for duplicates
    end

    # returns the abstract symbol for a given action. this is used to allow
    # different actions to be treated controlled as a single action, for example,
    # :list and :show are treated as a :view action. this should help simplify
    # creating policies and presenting UI to users.
    def normalize_action(action)
      action = action.to_sym if not action.is_a? Symbol
      return action if action == :any

      @@coalesced_actions.each { |abstract, actions|
        return abstract if abstract == action or actions.include? action
      }

      # as is
      action
    end

    # return the resource type to be used for looking up permissions.
    # resource arg may be a string or a symbol naming the resource type, or
    # an instance of Page, or Group. If no resource is given, the :system
    # resource type is used.
    def normalize_resource(resource)
      if resource.is_a? Group
        resource = :group
      elsif resource.is_a? Page
        resource = :page
        #resource = resource.class_display_name
      elsif not resource.is_a? Symbol
        resource = :system
      end

      resource.to_sym
    end

    # takes an action and an optional resource, and returns true if the
    # action is allowed on the given resource by this policy.
    # if no resource is given, the :system resource will be quried.
    def allows?(action, resource = :system)

      # must have an action, at least
      return false if action.blank?

      action = normalize_action(action)
      resource = normalize_resource(resource)

      if @@resource_rules.has_key?(resource) or @@resource_rules.has_key?(:any)

        permission = @@resource_rules.has_key?(resource) ?
                     @@resource_rules[resource] : @@resource_rules[:any]

        if permission.is_a? Symbol
          return true if permission == action or permission == :any
        elsif permission.respond_to? :include?
          return true if permission.include? action
          return true if permission.include? :any
        end
      end

      return false
    end


    # add an action to the list of allowed actions on resource type
    def allow(action, resource)
      @@resource_rules[resource] ||= []
      if action.is_a? Array
        @@resource_rules[resource].merge! action
      else
        @@resource_rules[resource] << action
      end
    end

    # remove an action from the list of allowed actions for resource type 
    def deny(action, resource)
      return unless @@resource_rules.has_key? resource
      return unless @@resource_rules[resource].include? action
      @@resource_rules[resource].delete action
    end
  end

  # Role: a role is functionally no different from a policy at
  # this point. they can be used to extend or limit a policy
  class Role
    def initialize(name = :anonymous)
      @policy = AuthorizedSystem.access_policy name
    end

    def name
      @policy.name
    end

    # return all permissions granted to this role
    def permissions
      @policy.resource_rules
    end

    # return all permissions granted to specific resource
    def permissions_for(resource)
      @policy.resource_rules[resource] ||= []
    end

    # role allowed to perform action on resource? just ask the policy
    def allows?(action, resource)
      @policy.allows? action, resource
    end
  end

  # access policies, starting their life as data objects.
  # TODO: move somewhere else

  # factory method, returns a policy for the named access level
  # defaulting to :anonymous
  def access_policy(role = :anonymous)
    case role
      when :administrator
        return AdministrativeAccess.new
      when :member
        return MembershipAccess.new
      when :user
        return AuthenticatedAccess.new
      else
        return AnonymousAccess.new
    end
  end
  module_function :access_policy

  # anonymous access policy
  class AnonymousAccess < Policy
    def initialize(name = 'anonymous')
      super name
      @@resource_rules.merge!({
        :any                => :none,
        :system             => :none,
      })
    end
  end

  # public (authenticated user) access policy
  class AuthenticatedAccess < AnonymousAccess
    def initialize(name = 'user')
      super name
      @@resource_rules.merge!({
        :page               => [:view, :comment],
        :vote               => [:view, :comment],
      })
    end
  end

  # group membership access policy
  class MembershipAccess < AuthenticatedAccess
    def initialize(name = 'member')
      super name
      @@resource_rules.merge!({
        :page               => [:view, :edit, :comment]
      })
    end
  end

  # administrative access policy
  class AdministrativeAccess < MembershipAccess
    def initialize(name = 'administrator')
      super name
      @@resource_rules.clear
      @@resource_rules = { :any => :any }
    end
  end

  protected 
    # return the effective role assigned to current user
    def current_role
      @current_role ||= assume_role
    end

    # authorization filter. called from app controller after #context has
    # been called. determines the appropriate role for the current user
    # based on current context.
    def assume_role
      # unathenticated users get the anonymous role
      if current_user.is_a?(UnauthenticatedUser)
        @current_role = Role.new :administrator
      else
        if @group
          # got a group and a user, use the membership's role
          @current_role = @group.role_for current_user
        else
          # if no specific group is identified, user gets
          # authenticated access 
          @current_role = Role.new :user
        end
      end

      @current_role
    end

    # add #current_role as a view helper
    def self.included(base)
      base.send :helper_method, :current_role
    end
end
