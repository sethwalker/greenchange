class MessagesController < ApplicationController

  before_filter :login_required
  def show
    @message = Message.find params[:id]
    raise PermissionDenied unless current_user.may? :view, @message
  end

  def create
    message_params = params[:message]
    message_params[:recipients] ||= @person.login if @person
    message_params[:sender_id] = current_user.id
    @messages = Message.spawn( message_params )
    @valid_messages, @invalid_messages = @messages.partition(&:valid?)
    @valid_messages.each(&:save)

    if !@valid_messages.empty?
      flash[:notice] = "Message sent to the following recipients: " + @valid_messages.map { |m| m.recipient.display_name }.join(", " )
    end
    redirect_to me_inbox_path and return if @invalid_messages.empty?

    @message = Message.new message_params
    @message.recipients = @invalid_messages.map { |m| m.recipients }.join(', ')
    @message.errors.add :recipients, "couldn't send to: " + @message.recipients
    render :action => 'new'
  end

  def new
    @message = current_user.messages_sent.new 
    @message.recipient = @person if @person
  end
  
  def index
    unless params[:message_action] == 'sent'
      @messages = Message.to(current_user).find :all#, :conditions => [ 'recipient_id = ?', current_user ]
    else
      @messages = Message.from( current_user ).find :all#, :conditions => [ 'sender_id = ?', current_user ]
    end
  end

  def destroy
    @message = Message.find params[:id]
    current_user.may! :admin, @message
    @message.destroy 
    flash[:notice] = "Removed message from #{@message.sender.display_name}"
    redirect_to :back
  end

  
end
