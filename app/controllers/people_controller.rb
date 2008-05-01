=begin
PeopleContoller
================================

A controller which handles collections of users, or
for creating new users.

For processing a single user, see PersonController.

=end

class PeopleController < ApplicationController
  layout 'application'
  include IconResource
  
  def show
    @person = User.enabled.find_by_login params[:id]
  end

  def index
    if logged_in?
      @contacts = current_user.contacts
      @peers = current_user.peers
    end
    @people = User.by_group(@group).by_person(( @me || @person)).by_issue(@issue).by_tag(@tag).enabled
  end

end
