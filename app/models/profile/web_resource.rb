class Profile::WebResource < ActiveRecord::Base
  set_table_name 'web_resources'
  validates_presence_of :web_resource_type
  validates_presence_of :web_resource

  belongs_to :profile#, :foreign_key => 'profile_id'

end
