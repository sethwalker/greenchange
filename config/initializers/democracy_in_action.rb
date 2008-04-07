DemocracyInAction.configure do
  begin
    config = YAML.load_file(File.join('config', 'democracy_in_action.yml'))

    auth.username = config[:auth][:username]
    auth.password = config[:auth][:password]
    auth.org_key =  config[:auth][:org_key]
  rescue Errno::ENOENT
    RAILS_DEFAULT_LOGGER.warn 'no democracy in action config'
  end

  #NOTE: mirror means save to DIA every time this object is saved, 
  #      AND delete from DIA when destroyed
  #
  #another NOTE:
  #      turns out it's better to just do this mapping from profile
#  mirror(:supporter, User) do
#    map('First_Name')     { |user| user.private_profile.first_name if user.private_profile }
#    map('Last_Name')      { |user| user.private_profile.last_name if user.private_profile }
#    map('Organization')   { |user| user.private_profile.organization if user.private_profile }
#  end

  mirror(:supporter, Profile) do
    guard { |profile| profile.entity.is_a?(User) }

    map('Email')          { |profile|
      user = profile.user
      user.email if user
    }
    map('First_Name')     { |profile| profile.first_name if profile.private? }
    map('Last_Name')      { |profile| profile.last_name if profile.private? }
    map('Organization')   { |profile| profile.organization if profile.private? }
  end

  #maybe don't need mirror here.  more like an after_create.
  mirror(:groups, Group) do
    map('parent_KEY', 50816)
    map('Group_Name')     { |group| group.name }
  end

  mirror(:supporter_groups, Membership) do
    map('supporter_KEY')  { |membership| 
      user = membership.user
      if user
        profile = user.private_profile
        if profile
          proxy = profile.democracy_in_action_proxies.find_by_remote_table('supporter')
          proxy.remote_key if proxy
        end
      end
    }
    map('groups_KEY')     { |membership| 
      group = membership.group
      if group
        proxy = group.democracy_in_action_proxies.find_by_remote_table('groups')
        proxy.remote_key if proxy
      end
    }
  end

#  mirror.event               = Event
#  c.mirror.supporter_event     = Attentance

=begin
  # if we had multiple tables per model
  mirror(:groups, User) do
    map('groups_KEY') { |user| user.democracy_in_action_list }
  end
=end
end

User.class_eval do
  attr_writer :democracy_in_action_list
  after_save :update_democracy_in_action_subscriptions
  def update_democracy_in_action_subscriptions
    # supporter_groups => supporter_KEY + @democracy_in_action_list
  end
end
