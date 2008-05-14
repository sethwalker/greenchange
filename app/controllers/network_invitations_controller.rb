class NetworkInvitationsController < ApplicationController
  before_filter :login_required

  def new
    @invite = NetworkInvitation.new
  end

  def create
    invites = NetworkInvitation.spawn( params[:invite].merge( :sender => current_user) )
    valid_invites, invalid_invites = invites.partition(&:valid?) 
    if invites.empty?
      flash[:error] = "You must include addresses"
      render :action => 'new' 
    elsif invalid_invites.empty?
      flash[:notice] = "Your invitations have been sent"
      redirect_to me_path
    else
      flash.now[:notice] = "Invitations were sent to: #{valid_invites.map(&:recipient_email).join(', ')}" unless valid_invites.empty? 
      @invite = NetworkInvitation.new 
      invalid_invites.each do |invite|
        invite.errors.each do |attr, msg|
          @invite.errors.add attr, msg
        end
      end
      @invite.recipients = invalid_invites.map(&:recipient_email).join(', ')
      @invite.body = params[:invite][:body]
      render :action => 'new'
    end
  end
end
