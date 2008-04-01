require File.dirname(__FILE__) + '/../spec_helper.rb'
describe 'check page access with webrat' do
  include PageUrlHelper
  
  before(:all) do
    @webrat = ActionController::Integration::Session.new
  end

  before do 
    @creator = create_valid_user
    @newbie = create_valid_user
    @page = create_valid_page
    @public_page = create_valid_page(:created_by_id => @creator.id, :public => true )
    [ @page, @public_page ].each { |p| p.update_attributes! :created_by_id => @creator.id  }
  end

  describe 'for a new page' do
    describe 'to the creating user' do
      before do
        @webrat.reset!
        login_test_user(@creator)
      end
      it 'should belong to the creating user' do
        Page.by_person(@creator).should include( @page )
        Page.by_person(@creator).should include( @public_page )
      end

      it 'should be viewable by the creating user' do
        @webrat.visits page_url(@page)
        @webrat.response.should be_success
      end
        
    end
    describe 'for a new user' do
      before do
        @webrat.reset!
        login_test_user(@newbie)
      end
      
      it 'non-public page should not be viewable' do
        #@webrat.visits edit_event_url(@page)
        @webrat.visits page_url(@page)
        #pp @webrat.response.body
        @webrat.response.body.should match( /do not have sufficient permission/)
      end
      it 'public page should be viewable' do
        pending "public page is viewable by all"
        @webrat.visits page_url(@public_page)
        #@webrat.response.should be_success
        @webrat.response.body.should_not match( /do not have sufficient permission/)
      end
    end
  
  end

  def login_test_user(test_user=nil)
    test_user ||= create_valid_user
    @webrat.visits "account/login"
    @webrat.fills_in "login", :with => test_user.login
    @webrat.fills_in "password", :with => test_user.password
    @webrat.clicks_button "Login"
  end
end


