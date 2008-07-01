class InboxController < ApplicationController
 
  before_filter :login_required
 
  def show
    @messages = @me.messages_received.pending.paginate(:all, :order => "updated_at DESC", :page => params[:page] )
    @join_requests = JoinRequest.to(@me).pending.paginate :all, :order => "updated_at DESC", :page => params[:page]
    @items_received = ( @messages + @join_requests ).sort { |item, item2 | item2.updated_at <=> item.updated_at }.compact

    @messages = @me.messages_received.pending.paginate(:all, :order => "updated_at DESC", :page => params[:page] )
    @join_requests = @me.join_requests.paginate :all, :order => "updated_at DESC", :page => params[:page]
    @items_sent= ( @messages + @join_requests ).sort { |item, item2 | item2.updated_at <=> item.updated_at }.compact

    @items_deleted = []
  end

  protected
  
  append_before_filter :fetch_user
  def fetch_user
    @user = current_user
  end
  
  # always have access to self
  def authorized?
    return true
  end
  
end
