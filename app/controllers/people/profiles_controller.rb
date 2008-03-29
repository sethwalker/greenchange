class People::ProfilesController < ProfilesController

  def show
    @person = params[:person_id] ?  User.find_by_login( params[:person_id] ) : current_user
    access_denied unless @profile = @person.profile_for(current_user)
    initialize_profile_collections
  end
  #def authorized?
  #current_user.is_a?( AuthenticatedUser) and super
  #end

end

