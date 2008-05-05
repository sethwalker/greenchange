require 'google_map'
require 'google_map_marker'
require 'calendar_dates/month_display.rb'
require 'calendar_dates/week.rb'

class Tool::EventController < Tool::BaseController

  helper :date
  helper :event_time 

  append_before_filter :fetch_event
  before_filter :login_required, :only => ['set_event_description', 'create', 'edit', 'new', 'update']

  def index
    calendar
    render :action => :calendar
  end

  def day
    list
  end

  def week
    list
  end

  def month
    list
  end

  def calendar
    list
    @month_display = MonthDisplay.new(@date)
  end
  
  def show
    @page = Tool::Event.find params[:id]
#    @user_participation= UserParticipation.find(:first, :conditions => {:page_id => @page.id, :user_id => current_user.id})  
#    if @user_participation.nil?
#      @user_participation = UserParticipation.new
#      @user_participation.user_id = current_user.id
#      @user_participation.page_id = @page.id
#      @user_participation.save
#    end    
    #@watchers = UserParticipation.find(:all, :conditions => {:page_id => @page.id, :watch => TRUE})  
    #@attendies =  UserParticipation.find(:all, :conditions => {:page_id => @page.id, :attend => TRUE})  

  end

  def edit
    @page = Tool::Event.find params[:id]
    raise PermissionDenied unless current_user.may? :admin, @page
  end
  
  def update
    @page = Tool::Event.find params[:id]
    raise PermissionDenied unless current_user.may? :admin, @page
    @event = @page.data
    # greenchange_note: currently, you aren't able to change a group
    # if one has already been set during event creation
    
    @event.attributes = params[:page].delete(:page_data)
    @page.attributes = params[:page]


    if @page.save and @event.save
      redirect_to(event_url(@page)) and return
    else
      message :object => @page
      render :action => 'edit' end
  end

  def new 
    @page = Tool::Event.new :group_id => params[:group_id], :starts_at => (TzTime.now.at_midnight + 9.hours).utc, :ends_at => (TzTime.now.at_midnight + 17.hours).utc, :public => true, :public_participate => true
    @event = @page.build_data(:time_zone => current_user.time_zone)
    @event.page = @page
  end

  def create
    @event = ::Event.new params[:page].delete(:page_data)
    @page = Tool::Event.new params[:page]

    # greenchange_note: all events are public right now per green change / seth
    @page.public = true

    @page.data = @event
    @page.created_by = current_user
    @event.page = @page
    if @page.save
      add_participants!(@page, params)
      return redirect_to(event_url(@page))
    else
      message :object => @page
      render :action => 'new'
    end
  end
 
  def set_event_description
    @event.description =  params[:value]
    @event.save
    render :text => @event.description_html
  end

  def participate
    @user_participation = UserParticipation.find(:first, :conditions => {:page_id => @page.id, :user_id => current_user.id})
    if !params[:user_participation_watch].nil? 
      @user_participation.watch = params[:user_participation_watch]
      @user_participation.attend = false
    else
      if !params[:user_participation_attend].nil?
        @user_participation.watch = false
        @user_participation.attend = params[:user_participation_attend]
      else
        @user_participation.watch = false
        @user_participation.attend = false
        # remove the user participation from the table?
      end
    end

    @user_participation.save
    
    @watchers = UserParticipation.find(:all, :conditions => {:page_id => @page.id, :watch => TRUE})
    @attendies =  UserParticipation.find(:all, :conditions => {:page_id => @page.id, :attend => TRUE})
    
  end
  
  protected

  def fetch_event
    return true unless @page
    @page.data ||= ::Event.new(:description => 'new event', :page => @page)
    @event = @page.data
  end
  
  def setup_view
  end
  
  # set the right time format for the event
  def set_time (time)
    time
  end

  def authorized?
    if @page and ( params[:action] == 'set_event_description' or params[:action] == 'edit' or params[:action] == 'update' )
      return current_user.may?(:admin, @page)
    else
      return true
    end
  end

  def request_dates
      if params[:date]
        year = params[:date].split("-")[0].to_i
        month = params[:date].split("-")[1].to_i
        day = params[:date].split("-")[2].to_i

        @date = Date.new(year,month, day)
      else
        @date = Date.today
      end

      if params[:by] == 'month'
        start_date  = @date.beginning_of_month
        end_date    = @date.end_of_month
      elsif params[:by] == 'day'
        start_date  = @date
        end_date    = start_date
      else # week is the default
        start_date  = @date.beginning_of_week 
        end_date    = @date.beginning_of_week + 6 
      end

      [start_date, end_date]
  end

  # returns array of events for the current user or group, depending on context
  def list
    @start_date, @end_date = request_dates

    if @group
      @events = @group.pages.page_type(:event).occurs_between_dates(
        @start_date.to_s, @end_date.to_s
      ).find(:all, :order => "pages.starts_at ASC")
    elsif @person
      @events = @person.pages.page_type(:event).occurs_between_dates(
        @start_date.to_s, @end_date.to_s
      ).find(:all, :order => "pages.starts_at ASC")
    else
      # TODO: will this ever be called? show public events? 
      @events = Page.public.page_type(:event).occurs_between_dates(
        @start_date.to_s, @end_date.to_s
      ).find(:all, :order => "pages.starts_at ASC")
    end

    @events.uniq!
  end
end
