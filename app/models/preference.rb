class Preference < ActiveRecord::Base
  belongs_to :user
  PREFERENCE_KEYS = Crabgrass::Config.user_preferences.map(&:first)
  #validates_inclusion_of :name, :in => PREFERENCE_KEYS
  validates_uniqueness_of :name, :scope => :user_id

  after_save :update_democracy_in_action
  def update_democracy_in_action
    if name =~ /subscribe_to_email_list|allow_info_sharing/ && !value
      democracy_in_action_proxies.destroy_all
    end
  end
end
