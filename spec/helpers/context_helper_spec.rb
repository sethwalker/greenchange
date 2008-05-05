require File.dirname(__FILE__) + '/../spec_helper'

describe ContextHelper do
  describe "scoped path" do
    before do
      @current_user = create_valid_user
      self.stub!(:current_user).and_return( @current_user )
    end

    it "should return the requested path" do
      self.scoped_path( :messages ).should == '/messages'
    end

    it "should include an action when requested" do
      self.scoped_path( :message, :action => :new ).should == '/messages/new'
    end

    it "should respect the current scope" do
      @group = create_valid_group
      self.scoped_path( :message, :action => :new ).should == "/groups/#{@group.to_param}/messages/new"
    end
    it "should respect a passed scope" do
      passable_group = create_valid_group
      self.scoped_path( :message, :action => :new, :scope => passable_group ).should == "/groups/#{passable_group.to_param}/messages/new"
    end

    it "should work for the me context" do
      @me = @current_user
      self.scoped_path( :messages ).should == "/me/messages"
    end
  end
end
