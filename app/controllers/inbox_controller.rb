class InboxController < ApplicationController
 
  before_filter :login_required
 
  #layout 'me'

  def show
    #ActiveRecord::Base.with_scope :order => "page.updated_at DESC", :page => params[:page]
    @messages = @me.messages_received.paginate(:all, :order => "updated_at DESC", :page => params[:page] )
    @contact_requests = @me.contact_requests_received.pending.paginate :all, :order => "updated_at DESC", :page => params[:page] 
    @membership_requests = @me.membership_requests_received_and_pending #.paginate :all, :order => "updated_at DESC", :page => params[:page]
    #@membership_requests = @me.membership_requests_received.pending.paginate :all, :order => "updated_at DESC", :page => params[:page]
    @membership_invitations = @me.membership_invitations #.paginate :all, :order => "updated_at DESC", :page => params[:page]
    @invitations = @me.invitations_received.paginate(:all, :order => "updated_at DESC", :page => params[:page] )
    @items = ( @messages + @contact_requests + @membership_requests + @membership_invitations + @invitations).sort { |item, item2 | item2.updated_at <=> item.updated_at }.compact

    respond_to do |format|
      format.html {}
      format.rss do
        options = {
          :title => 'Crabgrass Inbox', 
          :link => me_inbox_path,
          :image => avatar_url( @me.avatar || 0, :size => 'standard' ),
          :items => @messages
          }
          render :partial => 'pages/rss', :locals => options
      end
        
    end

  end

  def search
    if path.first == 'unread'
      @pages = current_user.pages_unread.paginate(:all, :page => params[:section], :order => "pages.updated_at DESC")#, :include => :user_participations)
    elsif path.first == 'pending'
      @pages = current_user.pages_pending.paginate(:all, :page => params[:section], :order => "pages.updated_at DESC")
    elsif path.first == 'starred'
      @pages = current_user.pages_starred.paginate(:all, :page => params[:section], :order => "pages.updated_at DESC")#, :include => :user_participations)
    elsif path.first == 'vital'
      @pages = current_user.vital_pages.paginate(:all, :page => params[:section], :order => "pages.updated_at DESC")#, :include => :user_participations)
    elsif path.first == 'type'
      @pages = current_user.pages.page_type(path[1]).paginate(:all, :page => params[:section], :order => "pages.updated_at DESC")
    else
      @pages = current_user.pages.paginate(:all, :page => params[:section], :order => "pages.updated_at DESC")#, :include => :user_participations)
    end
  end 

# post required
  # action for mass updates
  def update
    if params[:remove] 
      remove
    else
      ## add more actions here later
    end
  end

  # post required
  def remove
    to_remove = params[:page_checked]
    if to_remove
      to_remove.each do |page_id, do_it|
        if do_it == 'checked' and page_id
          page = Page.find_by_id(page_id)
          if page
            upart = page.participation_for_user(@user)
            upart.destroy
          end
        end
      end
    end
    redirect_to url_for(:controller => 'inbox', :action => 'index', :path => params[:path]) 
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
  
#  def context
#    me_context('large')
#    add_context 'inbox'.t, url_for(:controller => 'inbox', :action => 'index')
#  end
end
