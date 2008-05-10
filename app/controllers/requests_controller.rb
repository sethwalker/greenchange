class RequestsController < ApplicationController

  before_filter :login_required

  make_resourceful do
    actions :new, :create, :show
    response_for(:show ) { |format| format.html { redirect_to message_path( current_object ) }}
    response_for(:create) do |format| 
      format.html do 
        flash[:notice] = "Your request to join this group has been sent"
        redirect_to ( current_object.group? ? group_path( current_object.group) : me_inbox_path ) 
      end 
    end
  end

  def index
    @requests_received = JoinRequest.by_group( current_user.groups_administering ).pending.paginate :all, :page => params[:page], :per_page => 50
    @requests_sent = JoinRequest.from(current_user).pending.paginate :all, :page => params[:page], :per_page => 50
  end

  def ignore
    load_object
    before :ignore
    current_object.ignore!
    if current_object.ignored?
      after :ignore
      flash[:notice] = "Request ignored"
      redirect_to me_inbox_path
    else
      after :ignore_fails
      flash[:error] = "The request cannot be ignored"
      redirect_to me_inbox_path
    end
  end

  def approve
    load_object
    before :approve
    current_object.approve!
    if current_object.approved?
      after :approve
      flash[:notice] = "Request approved"
      redirect_to me_inbox_path
    else
      after :approve_fails
      flash[:error] = "The request cannot be approved"
    end
  end
    
  protected 
  
  def object_parameters
    defaults = super || {}
    requestable = {}
    requestable[:group] = @group if @group
    requestable[:event] = @event if @event
    requestable[:sender] = current_user
    unless defaults[:recipients]
      requestable[:recipients] ||= @person.login if @person
    end
    defaults.merge requestable
  end

  def get_request_type
    @request_type = params[:request_type]
  end

  def current_model_name
    "JoinRequest"
  end
  def instance_variable_name
    "join_requests"
  end

  
end
