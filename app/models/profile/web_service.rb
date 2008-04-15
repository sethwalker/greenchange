class Profile::WebService < ActiveRecord::Base
  set_table_name 'web_services'
  validates_presence_of :web_service_type
  validates_presence_of :web_service_handle

  belongs_to :profile#, :foreign_key => 'profile_id'

end
