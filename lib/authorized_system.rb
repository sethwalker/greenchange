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

      # action abstractions TODO: discuss these, come up with a full list
      @@view_actions     = [:view, :read, :show, :list]
      @@edit_actions     = [:edit, :change, :add, :update]
      @@comment_actions  = [:comment, :note, :vote, :star]
      @@delete_actions   = [:delete, :remove]

      # TODO: cross-check for duplicates
    end

    # returns the abstract symbol for a given action. this is used to allow
    # different actions to be treated controlled as a single action, for example,
    # :list and :show are treated as a :view action. this should help simplify
    # creating policies and presenting UI to users.
    def normalize_action(action)
      action = action.to_sym if not action.is_a? Symbol
      return action if action == :any

      # the first element holds the abstract form of the action
      [:view, :edit, :comment, :delete].each { |abstract|
        eval "return @@#{abstract}_actions.first if @@#{abstract}_actions.include? action"
      }

      # as is
      action
    end

    # return the resource type to be used for looking up permissions.
    # resource arg may be a string or a symbol naming the resource type, or
    # an instance of Page, or Group. If no resource is given, the :system
    # resource type is used.
    def normalize_resource(resource)
      if resource.blank?
        resource = :system
      elsif resource.is_a? Group
        resource = :group
      elsif resource.try( :class_display_name ) #and resource.class_display_name
        resource = resource.class_display_name
      elsif resource.is_a? Page
        resource = :page
      end
      resource = :system if resource.nil?

      resource.to_sym
    end

    # add an action to the list of allowed actions on given resource
    # type (a symbol)
    # NOTE: only used from spec so far
    def allow(action, resource)
      @@resource_rules[resource] ||= []
      @@resource_rules[resource] << action
    end

    # remove an action from the list of allowed actions for the given
    # resource type (a symbol)
    # NOTE: only used from spec so far
    def deny(action, resource)
      return unless @@resource_rules.has_key? resource
      return unless @@resource_rules[resource].include? action
      @@resource_rules[resource].delete action
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
          return true if permission == :* or permission == :any
          return true if permission == action
        #elsif permission.is_a? Proc
        # rules can be callbacks... someday
        elsif permission.respond_to? :include?
          return true if permission.include? action
          return true if permission.include? :any
        end
      end

      return "the '#{self.name}' role is not allowed to #{action} #{resource} resources"
      return false
    end
  end

  # Role: a role is functionally no different from a policy at
  # this point. they can be used to extend or limit a policy
  class Role
    def initialize(name = :anonymous)
      @policy = AuthorizedSystem.access_policy(name)
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
      @policy.resource_rules[resource]
    end

    # role allowed to perform action on resource? just ask the policy
    def allows?(action, resource)
      @policy.allows?(action, resource)
    end
  end

  # access policies, starting their life as data objects.
  # TODO: move somewhere else

  # factory method, returns a policy for the named access level
  # defaulting to :anonymous
  def access_policy(access = :anonymous)
    case access
      when :administrator
        return AdministratorAccess.new
      when :member
        return MemberAccess.new
      when :public
        return PublicAccess.new
      else
        return AnonymousAccess.new
    end
  end
  module_function :access_policy

  # anonymous access policy
  class AnonymousAccess < Policy
    def initialize
      super 'anonymous'
      @@resource_rules = {
        :any                => :none,
      }
    end
  end

  # public access policy
  class PublicAccess < Policy
    def initialize
      super 'public'
      @@resource_rules = {
        :wiki               => [:view, :edit],
        :vote               => [:view, :comment],
        :action_alert       => :view,
        :file               => :view,
        :blog               => :view,
        :bucket             => :view,
        :group_discussion   => [:view, :comment],
        :event              => :view,
        :external_video     => :view,
        :news               => :view,
        :ranked_vote        => :view,
        :approval_vote      => :view,
        :task_list          => :view,

        #:personal_message   => { :callback => :owned_by_user },

        :system             => :none,
      }
    end
  end

  # regular group member policy
  class MemberAccess < Policy
    def initialize
      super 'member'
      @@resource_rules = {
        :any            => [:view, :edit, :comment],
      }
    end
  end

  # administrative group member policy
  class AdministratorAccess < Policy
    def initialize
      super 'administrator'
      @@resource_rules = {
        :any                => :*,
        :system             => [:admin],
      }
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
    #
    # TODO: decide on default policy/role (see Role init method... public?)
    # TODO: can/will collections be part of the context?
    #
    def assume_role
      # unathenticated users get the anonymous role
      unless current_user
        @current_role = Role.new :anonymous
      else
        if @group
          # got a group and a user, use the membership's role
          @current_role = @group.role_for current_user
        else
          # if no specific group is identified, user gets the public role
          @current_role = Role.new :public
        end
      end

      # patch user class with may_* methods. this is not oh so cool and
      # has several problems, like :any and :none. needs more thinking
      # out
      #current_user.assume_role @current_role

      @current_role
    end

    # add #current_role as a view helper
    def self.included(base)
      base.send :helper_method, :current_role
    end
end
