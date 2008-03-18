require 'calendar_dates/month_display.rb'
require 'calendar_dates/week.rb'

class MyCalendarController < ApplicationController

  helper :date
  helper :event_time
  
  layout 'me'
  before_filter :login_required

  # events / calendar code - most of these actions adapted from
  # yossarian's indymedia calendar (with permission)

  # greenchange_note: perms and path will have to be adjusted to match
  # your system for all the actions below.  The datetime logic should
  # remain the same, but you will have to reconstruct your options /
  # perms / paths for the finding of events I have also had to heavily
  # modify the sql builder keywords and filters code to support the
  # more complex queries to support multi day event spans this code
  # could probably be refactored upon more time for further analysis
  # and optimization

  # for now, default index to calendar grid view
  def index
    redirect_to :action => 'calendar_month'
  end

  def list_by_day
    if params[:date] == nil
      @date = Date.today
    else
      @date = splitdate(params[:date])
    end  
    datestring = @date.to_s

    options = options_for_me(:public => true)
    @events = Page.find_by_path(build_day_path(datestring),options)
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
    datestring = @date.to_s
    datestring2 = (@date + 6).to_s

    options = options_for_me(:public => true)
    @events = Page.find_by_path(build_complex_path(datestring,datestring2),options)
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
    datestring = @date.to_s
    if @date.month < 12  # look for year rollover
      datestring2 = (Date.new(@date.year,@date.month+1)).to_s
    else
      datestring2 = (Date.new(@date.year+1, 1)).to_s
    end

    options = options_for_me(:public => true)
    @events = Page.find_by_path(build_complex_path(datestring,datestring2),options)
  end

  def calendar_month
    list_by_month
    @month_display = MonthDisplay.new(@date)
  end

  protected

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

  append_before_filter :fetch_user
  def fetch_user
    @user = current_user
  end
  
  # always have access to self
  def authorized?
    return true
  end
  
  def context
    me_context('large')
    add_context 'calendar'.t, url_for(:controller => 'my_calendar', :action => 'index')
  end
  
  
end
