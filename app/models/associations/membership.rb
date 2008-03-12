#
# user to group relationship
#
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base

  belongs_to :user
  belongs_to :group
  belongs_to :page

  validates_presence_of :role

  def role=(value)
    write_attribute :role, value.to_s
  end

  def role
    read_attribute(:role).to_sym unless read_attribute( :role ).blank?
  end
    
end

