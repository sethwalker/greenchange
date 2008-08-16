require File.dirname(__FILE__) + '/../spec_helper'

describe PreferencesController do
  before do
    login_user(@user = create_user)
  end
  describe "GET index" do
    before do
    end
    
    def act!
      get :index
    end

    it "should assign the user preferences to an instance var for the view" do
      act!
      assigns[:preferences].should == @user.preferences
    end

  end
  describe "POST #create" do
    before do
      @preference_attr = { :name => 'subscribe_to_email_list', :value => "0" }
    end
    def act!
      post :create, :preference => @preference_attr
    end
    it "should create new preferences" do
      lambda{ act! }.should change( @user.preferences, :count).by(1)
    end
    it "should not create new preferences that match existing values" do
      @user.preferences.create @preference_attr
      lambda{ act! }.should_not change( @user.preferences, :count)
    end
    it "returns ok when create is successful" do
      act!
      response.should be_success
    end
    it "returns failure when create biffs" do
      @pref = @user.preferences.create @preference_attr
      @pref_set = []
      @pref.stub!(:update_attributes).and_return(false)
      @pref_set.stub!(:find_or_create_by_name).and_return(@pref)
      @user.stub!(:preferences).and_return(@pref_set)
      
      act!
      response.should_not be_success
    end
  end
end
