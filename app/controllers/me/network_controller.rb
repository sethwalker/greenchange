class Me::NetworkController < PeopleController
before_filter :login_required

def index
	@people=current_user.contacts
	@groups=current_user.groups
end

end