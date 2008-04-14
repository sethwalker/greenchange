require File.dirname(__FILE__) + '/../spec_helper'
describe "Event" do

  before do
    @page = Tool::Event.create :title => 'test_event'
    @event = @page.create_data :page => @page
    TzTime.zone = TimeZone[DEFAULT_TZ]
  end

  it "should accept a start date" do
    @event.time_zone = 'Pacific Time (US & Canada)'
    @event.date_start = '2008-04-02'
    @event.hour_start = '12:00PM'
    @event.date_start.should == '2008-04-02'
  end

  it "should pull a start date from the page" do
    @event.page.starts_at = Time.mktime( 2008, 04, 2, 12 )
    @event.date_start.should == '2008-04-02'
  end

  it 'should compile a start time from start date and start time' do
    @event.date_start = '2008-04-02'
    @event.hour_start = '4:30 PM'
    @event.starts_at.should == Time.mktime( 2008, 04, 2, 16, 30, 00 )
  end

  it 'should compile a end time from end date and end time' do
    @event.date_end = '2008-04-02'
    @event.hour_end = '4:30 PM'
    @event.ends_at.should == Time.mktime( 2008, 04, 2, 16, 30, 00 )
  end

  it 'should save start time data to the page on save' do
    @event.date_start = '2008-04-02'
    @event.hour_start = '4:30 PM'
    @event.time_zone = 'Pacific Time (US & Canada)'
    @event.save
    @page.starts_at.should_not be_nil
  end

  describe "time zone conversions" do
    before do
      @event.date_start = '2008-04-02'
      @event.hour_start = '4:30 PM'
      @event.hour_end = '5:30 PM'
      @event.time_zone = 'Pacific Time (US & Canada)'
      @event.save
    end

    it "should store data on UTC" do
      @page.starts_at.should == TzTime.new( Time.mktime( 2008, 4, 3, 0, 30), TimeZone['London'] ).utc
      #@page.starts_at.should == TzTime.new( @event.date_start, @event.tz_time_zone ).utc
    end

    it "should give back the date in the current time zone" do
      @event.date_start.should == '2008-04-02'
    end
    it "should give back the time in the events time zone" do
      @event.hour_start.should == '04:30 PM'
    end
    
    it "should give back the end time in the events time zone" do
      @event.hour_end.should == '05:30 PM'
    end
    

  end

  describe "sequential changes" do
    before do
      @event.date_start = '2008-04-02'
      @event.hour_start = '4:30 PM'
      @event.hour_end = '5:30 PM'
      @event.time_zone = 'Pacific Time (US & Canada)'
      @event.save
    end
    it "should accept updates to these values from the event" do
      event = Event.find @event.id
      event.hour_end = '7:00 PM'
      event.save
      event.hour_end.should == '07:00 PM'
    end
  end
end
