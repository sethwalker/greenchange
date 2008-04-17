class RsvpsController < ApplicationController
  make_resourceful do 
    actions :all
    before (:create) do
      #raise params.inspect
      #raise object_parameters.inspect
    end
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
=begin
  def create
    @page = Tool::Event.find params[:event_id]
    @event = @page.data
    @rsvp = @event.rsvps.build(:user_id => current_user.id)
    if @rsvp.valid?
      @rsvp.save
      flash[:notice] = "You are marked as attending this event."
    else
      flash[:notice] = "Unable to mark you as attending this event."
    end
    redirect_to :back
  end
=end
end
