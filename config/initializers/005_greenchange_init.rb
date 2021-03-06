Crabgrass::Config.image_sizes = {
  :tiny     => '12x12',
  :xsmall   => '22x22',
  :small    => '24x24',
  :medium   => '48x48',
  :standard => '64x64',
  :large    => '92x92',
  :default  => '92x92'
}

Crabgrass::Config.user_preferences = [
    [:subscribe_to_email_list, 'Subscribe me to Green Change e-updates'], 
    [:allow_info_sharing, 'Share my information with other Green organizations'], 
    [:html_editor_level, 'HTML Editor preference'], 
]

Crabgrass::Config.profile_note_types = [ 
    [:blurb      , 'About Me'], 
    [:activism   , 'Social Change Interests'], 
    [:interests  , 'Personal Interests'], 
    [:work       , 'Work Life' ] ]

Crabgrass::Config.dia_subscribe_to_email_list_group_id = 34365
Crabgrass::Config.dia_allow_info_sharing_group_id =  34839
Crabgrass::Config.dia_all_members_group_id = 36056
Crabgrass::Config.dia_no_groups_group_id = 36057

Crabgrass::Config.chat_room_limit = 8

crabgrass_config = "#{RAILS_ROOT}/config/crabgrass.yml"
# kluge for cruise control for now
crabgrass_config = "#{RAILS_ROOT}/config/crabgrass_example.yml" unless File.exists? "#{RAILS_ROOT}/config/crabgrass.yml"
if File.exists? crabgrass_config
  crabgrass_settings = YAML::load(IO.read( crabgrass_config ))
  crabgrass_settings.symbolize_keys!

  DEFAULT_TZ = crabgrass_settings.delete(:default_time_zone) 
  crabgrass_settings.each{ |setting_name, value| Crabgrass::Config.send "#{setting_name}=".to_sym, value }
end
