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
    it "should render list template" do
      response.should render_template('list')
    end
  end
end
