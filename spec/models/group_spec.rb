require File.dirname(__FILE__) + '/../spec_helper'

describe Group do
  before do
    User.current = nil
    @group = Group.new :name => 'banditos_for_bush'
  end

  it "should have the same tags as its pages" do
    @page = create_valid_page
    @group.save!
    @group.pages << @page
    @page.tag_with 'crackers ninjas'
    @group.tags.map(&:name).should include('ninjas')
  end

  describe "months_with_pages_viewable_by_user" do
    describe "when checking the connection adapter" do
      it "recognizes sqlite" do
        Page.stub!(:connection).and_return(connection = stub('connection', :adapter_name => 'SQLite'))
        connection.should_receive(:select_all).with(%r{SELECT #{Regexp.escape(@group.sqlite_months_string)}})
        @group.months_with_pages_viewable_by_user(User.new)

      end
      it "recognizes mysql" do
        Page.stub!(:connection).and_return(connection = stub('connection', :adapter_name => 'MySQL'))
        connection.should_receive(:select_all).with(%r{SELECT #{Regexp.escape(@group.mysql_months_string)}})
        @group.months_with_pages_viewable_by_user(User.new)
      end
    end
    it "returns proper months" do
      @group.save
      @group.pages << create_valid_page(:created_at => Date.new(2007, 12))
      @group.pages << create_valid_page(:created_at => Date.new(2008, 2))
      @group.stub!(:allows?).and_return(true)
      months = @group.months_with_pages_viewable_by_user(User.new)
      months[0]['month'].should == '12'
      months[1]['year'].should == '2008'
    end
  end

end

