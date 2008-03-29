class Me::ProfilesController < ProfilesController

  def authorized?
    current_user.is_a?( AuthenticatedUser) and super
  end

end
