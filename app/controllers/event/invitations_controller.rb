class InvitationsController < ApplicationController
  def new
    if @event
      @invitation = EventInvitation.new
    elsif @group
      @invitation = MembershipInvitation.new
    end
  end

  def create
    debugger
    requested_users = params[:invitation][:user_names].split(/\s*[,\s]\s*/).compact
    real_users = requested_users.map do |login| 
      User.find_by_login login unless login.blank? 
    end.compact
    error_names = (requested_users - real_users.map(&:login)).select { |name| !name.blank? }
    error_text = "not found: #{error_names.join(', ')}" unless error_names.empty?
    attending_users = real_users.select { |user| @event.attendees.include? user }
    attending_text = "for attendees: #{attending_users.map(&:login).join(", ")}" unless attending_users.empty?
    real_users -= attending_users
    unless attending_text || error_text
      real_users.each do |user|  
        invitation = Invitation.new(:sender_id => current_user.id, :recipient_id => user.id)
        invitation.body = params[:invitation][:body]
        invitation.subject = "You've Been Invited to: #{@event_page.title}"
        invitation.invitable = @event
        invitation.save
      end     
      flash[:notice] = "Sent #{real_users.size} invitations to #{@event_page.title}"
      redirect_to event_url(@event_page)
    else    
      @invitation.user_names = real_users.map(&:login).join(', ')
      render :action => 'invite'
    end
  end

  def index
  end

  def accept
  end

  def destroy
  end
end
