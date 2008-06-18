require File.dirname(__FILE__) + '/../spec_helper'

describe ContactsController do
  before do
    @current_user = create_user
    login_user(@current_user)
    @user = create_user
  end

  describe "destroy" do
    it "should remove the contact" do
      @contact = Contact.create!( :user => @current_user, :contact => @user )
      Contact.stub!(:find).and_return(@contact)
  
      post :destroy, :id => 1
      @current_user.reload
      @current_user.contacts.should_not include(@user)
    end
  end
end
