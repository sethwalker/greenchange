class Profile::Language < ActiveRecord::Base
  belongs_to :profile
  belongs_to :user
  set_table_name :languages
  
end
