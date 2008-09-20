require 'svg/svg' 
require 'calendar_dates/month_display.rb'
require 'calendar_dates/week.rb'

class GroupsController < ApplicationController
  helper :profile

  helper :date
  helper :event_time
  include IconResource
    
  
  before_filter :find_group, :except => [:index, :new,:create]
  
  before_filter :login_required, :only => [:create, :update, :destroy, :new, :edit ]
    #:except => [:list, :index, :show, :search, :archive, :tags, :calendar_month, :list_by_day, :list_by_week, :list_by_month]
    
  #verify :method => :post,
  #  :only => [:create, :update, :destroy]

  def index
    if params[:query]
      @groups = Group.search(params[:query], :page => params[:page], :per_page => Group.per_page)
    else
      @groups = Group.allowed( current_user, :view ).by_person(( @me || @person)).by_issue(@issue).by_tag(@tag).paginate(:all, :page => params[:page])
      if scoped_by_context? && ( scoped_by_context? != current_user )
        @shared_groups = current_user.groups.shared(scoped_by_context?)
      end
    end
  end

  def show
    @pages = @group.pages.allowed(current_user, :view).find(:all, :order => 'pages.updated_at DESC', :limit => 20)
    @profile = @group.profile
    @wiki = @group.page
  end

  def new
    @group = Group.new 
  end

  # login required
  def create
    @parent = Group.find(params[:parent_id]) if params[:parent_id]

    if @parent
      unless current_user.superuser?  or current_user.member_of?(@parent)
        flash[:error] = 'you do not have permission to do that'
        redirect_to group_path(@parent) and return
      end
      @group = Committee.new(params[:group])
      @group.parent = @parent
    else
      @group = Group.new(params[:group])
    end

    if @group.save
      flash[:notice] = "Congrats.  You've started a new group."

      # group creator is its default administrator (TODO: is this assumption true???)
      @group.memberships.create :user => current_user, :group => @group, :role => 'administrator'
      redirect_to group_path(@group)
    else
      render :action => :new 
    end

  end

  # login required
  def edit
  end
    
  # login required
  # post required
  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to group_path(@group)
    else
      render :action => 'edit'
    end
  end
  
  # login required
  # post required
  def destroy
    current_user.may!( :admin, @group )
    if @group.users.uniq.size > 1 or @group.users.first != current_user
      flash[:error] = 'You can only delete a group if you are the last member'
      redirect_to group_path(@group)
    else
      @group.destroy
      if @group.parent
        redirect_to group_path(@group.parent)
      else
        redirect_to groups_path
      end
    end
  end  
     
  
=begin
  def tags
    @pages = @group.pages.allowed(current_user).tagged(params[:path]).paginate(:page => params[:section])
  end
=end

  def visualize
    unless logged_in? and current_user.member_of?(@group)
      message( :error => 'you do not have permission to do that', :later => true )
      redirect_to group_path(@group)
    end

    # return xhtml so that svg content is rendered correctly --- only works for firefox (?)    
    response.headers['Content-Type'] = 'application/xhtml+xml'       
  end

  # greenchange_note: Group event / calendar actions

  def list_by_day
    if params[:date] == nil
      @date = Date.today
    else
      @date = splitdate(params[:date])
    end  
    datestring = @date.to_s

    @events = @group.pages.page_type(:event).occurs_on_day(datestring).find(:all, :order => "pages.starts_at ASC")
  end
  
  def list_by_week
    if params[:date] == nil
      today = Date.today
      @date = Week.new(today).first_day_in_week
    else
      date = splitdate(params[:date])
      @date = Week.new(date).first_day_in_week
    end  
    list_one_week(@date)
  end
  
  def list_one_week(date)
    @date = date
    start_datestring  = @date.to_s
    end_datestring    = (@date + 6).to_s

    @events = @group.pages.page_type(:event).occurs_between_dates(start_datestring, end_datestring).find(:all, :order => "pages.starts_at ASC")
  end

  def list_by_month
    if params[:date] == nil
      today = Date.today
      year = today.year
      month = today.month
    else
      year = params[:date].split("-")[0].to_i
      month = params[:date].split("-")[1].to_i
    end  
    @date = Date.new(year,month)
    start_datestring = @date.to_s
    if @date.month < 12  # look for year rollover
      end_datestring = (Date.new(@date.year,@date.month+1)).to_s
    else
      end_datestring = (Date.new(@date.year+1, 1)).to_s
    end

    @events = @group.pages.page_type(:event).occurs_between_dates(start_datestring, end_datestring).find(:all, :order => "pages.starts_at ASC")
  end

  def calendar_month
    list_by_month
    @month_display = MonthDisplay.new(@date)
  end
    
  protected
  
#  def context
#    group_context
#    unless ['show','index','list'].include? params[:action]
#      add_context params[:action], url_for(:controller=>'groups', :action => params[:action], :id => @group, :path => params[:path])
#      # url_for is used here to capture the path
#    end
#  end
  
  def find_group
    @group ||= Group.find_by_name(params[:id])  
    raise ActiveRecord::RecordNotFound unless @group
  end

  def authorized?
    non_members_post_allowed = %w(archive search tags tasks create)
    non_members_get_allowed = %w(new show members calendar_month list_by_day list_by_week list_by_month) + non_members_post_allowed
    if request.get? and non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and non_members_post_allowed.include? params[:action]
      return true
    else
      return(logged_in? and @group.allows?(current_user, params[:action]))
    end
  end    

=begin
  def edit_profile
    @profile = @group.public_profile
    @profile.save_from_params(params[:profile]) if request.post?
  end
=end

  # Protected calendar / event methods

  def splitdate(datestring)
    year = datestring.split("-")[0].to_i
    month = datestring.split("-")[1].to_i
    day = datestring.split("-")[2].to_i  
    date = Date.new(year, month, day)
    date
  end
  
  def event_path
    # greenchange_note: bypass current bug in sql builder per elijah's
    # instructions.. need to revisit these perms for crabgrass trunk

    #    "/type/event/#{params[:participate]||'interesting'}/ascending/starts_at/starts/"
    "/type/event/ascending/starts_at/"
  end

  # builds simpler case when resolution is one day
  def build_day_path(datestring)
    event_path + "event_starts/event_starts_before/#{datestring.to_date}/event_ends/event_ends_after/#{datestring.to_date}"
  end

  # greenchange_note: not sure how your system will work below, but there
  # are four types of cases to test for and this could probably be refactored
  # once there is more time for analysis, this does work though.

  # builds complex case when resolution greater than one day and you need
  # to detect up to four distinct types of event time intersections with
  # the resolution bounds
  def build_complex_path(datestring,datestring2)

    # event start/end at resolution bounds or within
    type1 = "event_starts/event_starts_after/#{datestring.to_date}/event_starts_before/#{datestring2.to_date}/event_ends/event_ends_after/#{datestring.to_date}/event_ends_before/#{datestring2.to_date}/"

    # event start/end spanning start of resolution bounds
    type2 = "or/event_starts_before/#{datestring.to_date}/event_starts_before/#{datestring2.to_date}/event_ends_after/#{datestring.to_date}/event_ends_before/#{datestring2.to_date}/"

    # event start/end spanning end of resolution bounds
    type3 = "or/event_starts_after/#{datestring.to_date}/event_starts_before/#{datestring2.to_date}/event_ends_after/#{datestring.to_date}/event_ends_after/#{datestring2.to_date}/"

    # event start/end is larger then resolution bounds
    type4 = "or/event_starts_before/#{datestring.to_date}/event_starts_before/#{datestring2.to_date}/event_ends_after/#{datestring.to_date}/event_ends_after/#{datestring2.to_date}"

    event_path + type1 + type2 + type3 + type4
  end


end
