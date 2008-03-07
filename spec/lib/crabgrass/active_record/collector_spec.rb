require File.dirname(__FILE__) + '/../../../spec_helper'

describe "Model::Collector" do

  before :all do
    User.__send__ :include, Crabgrass::ActiveRecord::Collector
    User.__send__ :has_collections, :private, :social, :public, :unrestricted
  end

  before do
    @user = create_valid_user
  end

  it "should have a class var for collections" do
    User.class_variables.should include("@@collections")
  end
  it "should have a private collection" do
    @user.private_collection.should be_an_instance_of(Collection)
  end

  it "should save all collections to the database on create" do
    Collection.find_all_by_user_id(@user).size.should == 4
  end

  it "should still have the collections after being reloaded" do
    #@user.save!
    new_user = User.find @user.id
    new_user.public_collection.should be_an_instance_of(Collection)
  end

  it "should create finders" do
    #@user.pages.private.should_not be_nil
  end

  describe "for finding pages" do

    before do
      @user.private_collection.pages << create_valid_page
      @user.public_collection.pages << create_valid_page
      @user.social_collection.pages << create_valid_page
      @user.unrestricted_collection.pages << create_valid_page
    end

    it "should limit private pages to the private selector"
    it "should show bouth unrestricted and public pages to  the public"
    it "should show public., unrestricted, and social pages to contacts" do
      pending "working allowed"
      @user.pages.allowed(contact).size.should == 3
    end
  end

end
