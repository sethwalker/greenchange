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
]

Crabgrass::Config.profile_note_types = [ 
    [:blurb      , 'About Me'], 
    [:activism   , 'Social Change Interests'], 
    [:interests  , 'Personal Interests'], 
    [:work       , 'Work Life' ] ]

if File.exists? "#{RAILS_ROOT}/config/crabgrass.yml"
  crabgrass_settings = YAML::load(IO.read("#{RAILS_ROOT}/config/crabgrass.yml"))
  crabgrass_settings.symbolize_keys!

  DEFAULT_TZ = crabgrass_settings.delete(:default_time_zone) 
  crabgrass_settings.each{ |setting_name, value| Crabgrass::Config.send "#{setting_name}=".to_sym, value }
end
