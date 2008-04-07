DemocracyInAction.configure do

  mirror(:supporter, User) do
    map('First_Name')     { |user| user.private_profile.first_name if user.private_profile }
    map('Last_Name')      { |user| user.private_profile.last_name if user.private_profile }
    map('Organization')   { |user| user.private_profile.organization if user.private_profile }
  end

  #maybe don't need mirror here.  more like an after_create.
  mirror(:groups, Group) do
    map('parent_KEY', 50816)
    map('Group_Name')     { |group| group.name }
  end

  mirror(:supporter_groups, Membership) do
    map('supporter_KEY')  {|membership| membership.user.democracy_in_action_key}
    map('groups_KEY')     {|membership| membership.group.democracy_in_action_key}
  end

#  mirror.event               = Event
#  c.mirror.supporter_event     = Attentance

end

User.class_eval do
  attr_writer :democracy_in_action_list
  after_save :update_democracy_in_action_subscriptions
  def update_democracy_in_action_subscriptions
    # supporter_groups => supporter_KEY + @democracy_in_action_list
  end
end
