class RsvpsController < ApplicationController
  make_resourceful do 
    actions :all
    response_for :create do |format|
      format.html do
        flash[:notice] = "You have been marked as attending this event."
        redirect_to :back
      end
    end
    response_for :destroy do |format|
      format.html do
        flash[:notice] = "Your RSVP has been destroyed."
        redirect_to :back
      end
    end
  end
end
