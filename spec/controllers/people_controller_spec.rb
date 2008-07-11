require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do
  it "should be properly tested" do
    pending
  end
  describe "index" do
    before do
      get :index
    end
    it "should be success" do
      response.should be_success
    end
    it "should render index template" do
      response.should render_template('index')
    end
  end
  describe "search people" do
    def act! 
      get :index, {:query => "first name"}
    end
    it "should search for people by login" do
      User.should_receive(:search).with("first name", :with => {:searchable => 1})
      act!
    end
  end
end
