#
# user to group relationship
#
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base

  belongs_to :user
  belongs_to :group
  belongs_to :page

  validates_presence_of :user_id, :group_id, :role

  def role=(value)
    write_attribute :role, value.to_s
  end

  def role
    read_attribute(:role).to_sym unless read_attribute( :role ).blank?
  end

  def admin?
    role == :administrator
  end

  def promote
    unless admin?
      self.role = :administrator
      save
    end
  end

  after_destroy :add_to_democracy_in_action_group
  def add_to_democracy_in_action_group
    return if user.memberships.count > 0
    return if DemocracyInAction::API.disabled?
    auth = DemocracyInAction::Auth
    api = DemocracyInAction::API.new 'authCodes' => [auth.username, auth.password, auth.org_key]
    no_groups_key = api.process('supporter_groups', 'supporter_KEY' => supporter_key(user), 'groups_KEY' => Crabgrass::Config.dia_no_groups_group_id)
    DemocracyInAction::Proxy.create :name => 'no_groups_group_membership', :local_type => 'User', :local_id => user_id, :remote_table => 'supporter_groups', :remote_key => no_groups_key
  end
  def supporter_key(user)
    user.private_profile.democracy_in_action_proxies.find_by_remote_table('supporter').remote_key
  end

  after_create :remove_from_democracy_in_action_group
  def remove_from_democracy_in_action_group
    DemocracyInAction::Proxy.find_by_local_type_and_local_id_and_name('User', user_id, 'no_groups_group_membership').try(:destroy)
  end
    
  after_create :created_network_event
  def created_network_event
    @created_network_event ||= NetworkEvent.create! :modified => self, :action => 'create', :user => user, :recipients => watchers, :data_snapshot => {:group => group, :user => user}
  end

  before_destroy :destroyed_network_event
  def destroyed_network_event
    @destroyed_network_event ||= NetworkEvent.create! :modified => self, :action => 'destroy', :user => user, :recipients =>watchers, :data_snapshot => {:group => group, :user => user}
  end

  def watchers
    user.contacts + group.admins
  end

end
