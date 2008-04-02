class Me::NetworkController < PeopleController
before_filter :login_required

def index
	@people=current_user.contacts
	@groups=current_user.groups
  @pages = Page.in_network(current_user).allowed(current_user).find(:all, :order => "updated_at DESC", :limit => 40)
end

end
