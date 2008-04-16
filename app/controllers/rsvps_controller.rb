class RsvpsController < ActionController::Base
  def create
    @page = Tool::Event.find params[:event_id]
    @event = @page.data
    @rsvp = @event.rvsps.build(:user_id => current_user.id)
    if @rsvp.valid?
      @rsvp.save
      flash[:notice] = "You are marked as attending this event."
    else
      flash[:notice] = "Unable to mark you as attending this event."
    end
    redirect_to me_inbox_path
  end
end
