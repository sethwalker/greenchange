require File.dirname(__FILE__) + '/../spec_helper'

describe Collecting do

  before do
    @collection = Collection.create :permission => :social
    @page = create_valid_page
    @collecting = Collecting.create :collection => @collection, :collectable => @page
  end

  it "should have the same permission as the collection" do
    @collecting.permission.should == @collection.permission
  end

  it "should not allow unauthenticater users to find editable things" do
    Collecting.allowed( UnauthenticatedUser.new, :edit ).find(:all).should be_empty
  end

  it "should offer a global policy for actions based on the collection policy" do
    Collecting.permissions_for_global(:view).should include('public')
  end

  it "should allow unauthenticated users to view public things" do
    collection = Collection.create :permission => :unrestricted
    page = create_valid_page
    collecting = Collecting.create! :collection => collection, :collectable => page
    
    Collecting.allowed( UnauthenticatedUser.new ).size.should == 1
  end

  describe "when dealing with private collections" do

    before do
      User.delete_all
      @owning_user = create_valid_user    :login => "yoko"
      @searching_user = create_valid_user :login => "jimbo"
      @owning_user.public_collection  << ( @public_page = create_valid_page )
      @owning_user.social_collection  << ( @social_page = create_valid_page )
      @owning_user.private_collection << ( @private_page = create_valid_page )
    end

    it "should allaw the owning user to see all pages" do
      Collecting.allowed( @owning_user ).size.should == 3
    end

    it "should allow the searching user to see only public pages" do
      Collecting.allowed( @searching_user ).size.should == 1
    end

    it "should share the social collection when the searching user is a contact" do
      @owning_user.contacts << @searching_user
      Collecting.allowed( @searching_user ).size.should == 2
    end

    it "should accept further conditions" do
      Collecting.allowed( @searching_user ).find(:all, :conditions => [ "collectable_type = ?", 'page']).size.should == 1
    end
  end
end

