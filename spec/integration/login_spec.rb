require File.dirname(__FILE__) + '/../spec_helper.rb'
describe 'Login with webrat' do

  describe 'create contact' do
    before(:all) do
      @webrat = ActionController::Integration::Session.new
    end

    before(:each) do
      @webrat.reset!
      login_test_user
    end

  
    it "can log in" do
      @webrat.reset!
      login_test_user
      @webrat.response.should be_redirect
      #@webrat.response.body.should match(/Inbox/)
    end
    
    it "shows the dashboard" do
      @webrat.visits '/me'
      @webrat.response.should be_success
    end
    it "shows the dashboard and the inbox" do
      @webrat.visits '/me'
      @webrat.visits '/me/inbox'
      @webrat.response.should be_success
    end


  end

  def login_test_user
    @test_user ||= create_valid_user
    @webrat.visits( '/login' )
    @webrat.fills_in "login", :with => @test_user.login
    @webrat.fills_in "password", :with => @test_user.password
    @webrat.clicks_button "Login"
  end
end


