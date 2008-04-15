class Preference < ActiveRecord::Base
  belongs_to :user
  PREFERENCE_KEYS = Crabgrass::Config.user_preferences.map(&:first)
  #validates_inclusion_of :name, :in => PREFERENCE_KEYS
end
