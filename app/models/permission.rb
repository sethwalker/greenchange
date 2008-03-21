class Permission < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :grantor,  :polymorphic => true
  belongs_to :grantee,  :polymorphic => true

  validates_presence_of :resource_type, :resource_id
  validates_presence_of :grantor_type,  :grantor_id
  validates_presence_of :grantee_type,  :grantee_id

  def Permission.grant(action, resource, grantor, grantee)
    permission = Permission.new(
      :resource => resource,
      :grantor => grantor,
      :grantee => grantee
    )

    if permission.respond_to? "#{action}="
      eval "permission.#{action} = 1"
    end

    permission.save! if permission.any?
  end

  def Permission.revoke(action, resource, grantor, grantee)
    raise RuntimeError, "Permission.revoke is not implemented yet"
  end

  def any?
    [:view, :edit, :participate, :admin].each {|action|
      eval "return true if self.#{action} == 1"
    }
    return false
  end

  def empty?
    not any?
  end
end
