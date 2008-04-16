class InvitationsController < ApplicationController
  def new
    if @event
      @invitation = EventInvitation.new
    elsif @group
      @invitation = MembershipInvitation.new
    end
  end

  def create
  end

  def index
  end

  def accept
  end

  def destroy
  end
end
