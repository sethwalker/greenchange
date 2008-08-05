class InboxController < ApplicationController
 
  before_filter :login_required
 
  def show
    messages_rcvd = @me.messages_received.pending.paginate(:all, :order => "updated_at DESC", :page => params[:page] )
    join_requests_rcvd = JoinRequest.to(@me).pending.paginate :all, :order => "updated_at DESC", :page => params[:page]
    @items_received = ( messages_rcvd + join_requests_rcvd ).sort { |item, item2 | item2.updated_at <=> item.updated_at }.compact

    @items_sent = @me.messages_sent.pending.paginate(:all, :order => "updated_at DESC", :page => params[:page] )

    messages_ignd = @me.messages_received.ignored.paginate(:all, :order => "updated_at DESC", :page => params[:page] )
    join_requests_ignd = JoinRequest.to(@me).ignored.paginate :all, :order => "updated_at DESC", :page => params[:page]
    @items_ignored = ( messages_ignd + join_requests_ignd ).sort { |item, item2 | item2.updated_at <=> item.updated_at }.compact
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
