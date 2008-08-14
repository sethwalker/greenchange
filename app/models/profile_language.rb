class ProfileLanguage < ActiveRecord::Base
  belongs_to :profile
  belongs_to :user
  set_table_name :languages
  
  belongs_to :language_string, :foreign_key => 'language'
end
