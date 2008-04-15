class MessagesController < ApplicationController

  before_filter :login_required
  def show
    @message = Message.find params[:id]
    raise PermissionDenied unless current_user.may? :view, @message
  end

  def create
  end

  def new
    @message = current_user.messages.create :recipient => @person
  end
  
  def index
    unless params[:message_action] == 'sent'
      @messages = Message.find :all, :conditions => [ 'recipient_id = ?', current_user ]
    else
      @messages = Message.find :all, :conditions => [ 'sender_id = ?', current_user ]
    end
  end
  
end
