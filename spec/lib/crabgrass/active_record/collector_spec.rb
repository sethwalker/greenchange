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

end
