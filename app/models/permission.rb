class Permission < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true
  belongs_to :grantor,  :polymorphic => true
  belongs_to :grantee,  :polymorphic => true

  validates_presence_of :resource_type, :resource_id
  validates_presence_of :grantor_type,  :grantor_id
  validates_presence_of :grantee_type,  :grantee_id

  def Permission.fetch(resource, grantor, grantee)
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

  def Permission.exists(resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    return false if permission.nil?
    true
  end

  def Permission.granted?(action, resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    return false if permission.nil?
    return permission.send(action) if permission.respond_to? action
    false
  end

  def Permission.grant(action, resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    if permission.nil?
      permission = Permission.new(
        :resource => resource,
        :grantor => grantor,
        :grantee => grantee
      )
    end

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

  def Permission.revoke(action, resource, grantor, grantee)
    permission = Permission.fetch(resource, grantor, grantee)
    unless permission.nil?

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

  def any?
    [:view, :edit, :participate, :admin].each {|action|
      return true if self.send "#{action}"
    }
    return false
  end

  def empty?
    not self.any?
  end
end
