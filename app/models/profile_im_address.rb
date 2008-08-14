=begin

=end

class ProfileImAddress < ActiveRecord::Base
  set_table_name 'im_addresses'
  validates_presence_of :im_type
  validates_presence_of :im_address

  belongs_to :profile#, :foreign_key => 'profile_id'

  #after_save {|record| record.profile.save if record.profile}
  #after_destroy {|record| record.profile.save if record.profile}

end
