class MessagesController < ApplicationController

  before_filter :login_required
  def show
    @message = Message.find params[:id]
    raise PermissionDenied unless current_user.may? :view, @message
  end

  def create
    @message = Message.new params[:message]
    @message.sender = current_user
    @message.recipient = @person
    if @message.save
      flash[:notice] = "Message sent"
      redirect_to me_inbox_path
    else
      render :new
    end
  end

  def new
    @message = current_user.messages_sent.new :recipient_id => @person.id
  end
  
  def index
    unless params[:message_action] == 'sent'
      @messages = Message.find :all, :conditions => [ 'recipient_id = ?', current_user ]
    else
      @messages = Message.find :all, :conditions => [ 'sender_id = ?', current_user ]
    end
  end

  def destroy
    message = Message.find params[:id]
    current_user.may! :admin, message
    message.destroy 
    flash[:notice] = "Removed message from #{message.sender.display_name}"
    redirect_to :back
  end
  
end
