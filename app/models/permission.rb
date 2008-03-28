class Permission < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true
  belongs_to :grantor,  :polymorphic => true
  belongs_to :grantee,  :polymorphic => true

  validates_presence_of :resource_type, :resource_id
  validates_presence_of :grantor_type,  :grantor_id
  validates_presence_of :grantee_type,  :grantee_id

  ACTION_ALIASES = {
    :view           => [:read, :show],
    :participate    => [:comment, :vote],
    :edit           => [:change],
    :admin          => [:delete]
  }

  # fetch the permission record for the given resource, grantor, and grantee
  def Permission.fetch(resource, grantor, grantee)
    return nil if resource.nil? or resource.is_a? Symbol
    return nil if grantor.nil?
    return nil if grantee.nil?

    permission = Permission.find(:first,
      :conditions => [
        "resource_type = ? AND resource_id = ? AND "+
        "grantor_type = ?  AND grantor_id = ? AND "+
        "grantee_type = ?  AND grantee_id = ? ",
        resource.class.base_class.name.to_s, resource.id,
        grantor.class.base_class.name.to_s, grantor.id,
        grantee.class.base_class.name.to_s, grantee.id
      ]
    )
  end

  # return true if a permission record exists for the given permission,
  # grantor, and grantee.
  def Permission.exists(resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    return false if permission.nil?
    true
  end

  # return true if a permission record exists for the given permission,
  # grantor, and grantee that grants the specified action
  def Permission.granted?(action, resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    return false if permission.nil?

    action = Permission.alias_for(action)
    return permission.send(action) if permission.respond_to? action

    false
  end

  # create or update a permission record for the given resource, etc.
  def Permission.grant(action, resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    if permission.nil?
      permission = Permission.new(
        :resource => resource,
        :grantor => grantor,
        :grantee => grantee
      )
    end

    action = Permission.alias_for(action)

    if action == :admin
      permission.admin        = true
      permission.edit         = true
      permission.participate  = true
      permission.view         = true
    elsif action == :edit
      permission.edit         = true
      permission.participate  = true
      permission.view         = true
    elsif action == :participate
      permission.participate  = true
      permission.view         = true
    elsif action == :view
      permission.view         = true
    end

    if permission.any?
      permission.save
    else
      permission.destroy
    end
  end

  # revoke the specified action from a permission record, deleting the
  # permission record if revoking all actions (i.e revoking :view)
  def Permission.revoke(action, resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    unless permission.nil?

      action = Permission.alias_for(action)

      if action == :view
        permission.view         = false
        permission.participate  = false
        permission.edit         = false
        permission.admin        = false
      elsif action == :participate
        permission.participate  = false
        permission.edit         = false
        permission.admin        = false
      elsif action == :edit
        permission.edit         = false
        permission.admin        = false
      elsif action == :admin
        permission.admin        = false
      end

      if permission.any?
        permission.save
      else
        permission.destroy
      end
    end
  end

  # returns true if at least one action is granted
  def any?
    [:view, :edit, :participate, :admin].each {|action|
      return true if self.send "#{action}"
    }
    return false
  end

  # returns true if no actions are granted
  def empty?
    not self.any?
  end

  def self.alias_for( aliased_action )
    logger.debug "### checking aliases for #{aliased_action}"
    ACTION_ALIASES.each do | action, aliases |
        return action if action == aliased_action
        return action if aliases.include? aliased_action
    end
    false
  end
end
