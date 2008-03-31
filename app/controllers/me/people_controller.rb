class Me::PeopleController < PeopleController
before_filter :login_required

def index
	@people=current_user.contacts
end

end