class Collecting < ActiveRecord::Base
  belongs_to :collection
  belongs_to :collectable, :polymorphic => true
  attr_protected :permission

  has_finder :allowed, Proc.new { | user, perm | 
    perm ||= :view
    ##not_logged_in
    if user.is_a?( UnauthenticatedUser ) and perm != :view
      { :conditions => "FALSE" }
    ##unspecified
    elsif user.nil? || user.is_a?(UnauthenticatedUser)
      { :conditions => [ "collectings.permission in(?)", Collecting.permissions_for_global(perm)] } 
    else
    ##specific user
      { :conditions => [ "collectings.permission in(?) OR collectings.collection_id in(?)", Collecting.permissions_for_global(perm), user.restricted_collection_ids(perm)] }
    end
  }

  #TODO replace this with more robust policy tool
  def self.permissions_for_global(action)
    global_allow = {
      :view => [ :public, :unrestricted ],
      :edit => [ :unrestricted ],
      :comment => [:public, :unrestricted ]
    }
    global_allow[action].map(&:to_s)
  end

  validates_presence_of :collection_id
  before_save :assign_permission

  def assign_permission
    self.permission = self.collection.permission.to_s unless self.collection.permission.nil?
  end

  def permission=(value)
    super value.to_s
  end

  def permission
    super.to_sym unless super.nil?
  end

  def collection_id=(value)
    super value
    assign_permission
    value
  end
end
