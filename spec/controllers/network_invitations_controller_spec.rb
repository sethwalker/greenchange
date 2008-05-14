require File.dirname( __FILE__ ) + '/../spec_helper'

describe NetworkInvitationsController do
  before do
    @user = login_valid_user
  end

  describe "network invitations" do
    def act!
      post :create, :invite => @invite_attrs
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
        response.should render_template( :new )
      end
    end
    describe "post without recipients" do
      integrate_views
      before do
        @invite_attrs = { :body => 'cheese', :recipients => ' ' } 
      end
      it "should re-load the form with errors" do
        act!
        response.should render_template(:new)
        response.body.should match(/include addresses/)
      end
    end

  end
end
