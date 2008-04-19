require File.dirname(__FILE__) + '/../spec_helper'

describe MeController do
  before do
    @user = login_valid_user
  end
  describe "search" do
    it "should set @pages" do
      get :search
      assigns[:pages].should_not be_nil
    end
    it "@pages should be a paginated collection" do
      get :search
      assigns[:pages].should be_a_kind_of(WillPaginate::Collection)
    end
  end

  describe "files" do
    it "should set @pages" do
      get :files
      assigns[:pages].should_not be_nil
    end
  end

  describe "tasks" do
    it "shouldn't raise an error" do
      lambda { get :tasks }.should_not raise_error
    end
  end

  describe "network invitations" do
    def act!
      post :send_invitation, :invite => @invite_attrs
    end
    describe "successful post" do
      before do
        @invite_attrs = { :body => 'cheese', :recipients => 'carrots@carrots.com, pb@pb.com' } 
      end
      it "should redirect to the user home page" do
        act!
        response.should redirect_to( me_path )
      end
    end

    describe "unsuccessful post" do
      before do
        @invite_attrs = { :body => 'cheese', :recipients => 'carrots@carrots.com, pb' } 
      end
      it "should re-load the form with errors" do
        act!
        response.should render_template( :invite )
      end
    end
    describe "post without recipients" do
      integrate_views
      before do
        @invite_attrs = { :body => 'cheese', :recipients => ' ' } 
      end
      it "should re-load the form with errors" do
        act!
        response.should render_template(:invite)
        response.body.should match(/include addresses/)
      end
    end

  end
end
