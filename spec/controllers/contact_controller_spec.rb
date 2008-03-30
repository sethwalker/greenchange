require File.dirname(__FILE__) + '/../spec_helper'

describe ContactController do
  before do
    @current_user = create_user
    login_user(@current_user)
    @user = create_user
  end

  describe "add" do
    it "should render the add template" do
      get :add, :id => @user.login
      response.should render_template("add")
    end
  end

  describe "create" do
    describe "when it is a new contact request" do
      it "should make a new ContactRequest" do
        post :create, :id => @user.login
        ContactRequest.find_by_user_id_and_contact_id(@current_user.id, @user.id).should_not be_nil
      end
      it "should save the message" do
        post :create, :id => @user.login, :message => 'the message'
        ContactRequest.find_by_user_id_and_contact_id(@current_user.id, @user.id).message.should == 'the message'
      end
    end
  end

  describe "remove" do
    it "should render the remove template" do
      get :remove, :id => @user.login
      response.should render_template('remove')
    end
  end

  describe "destroy" do
    it "should remove the contact" do
      @current_user.contacts << @user
      post :destroy, :id => @user.login
      @current_user.reload
      @current_user.contacts.should_not include(@user)
    end
  end

  describe "requests" do
    it "should find the contact request" do
      ContactRequest.should_receive(:find).with('2').and_return(ContactRequest.new(:user => @current_user))
      get :requests, :id => 2
    end
  end

  describe "approve" do
    it "should receive approved!" do
      req = ContactRequest.new :contact => @current_user
      req.should_receive(:approve!)
      ContactRequest.should_receive(:find).with('2').and_return(req)
      post :approve, :id => 2
    end
  end

  describe "reject" do
    it "should receive reject!" do
      req = ContactRequest.new :contact => @current_user
      req.should_receive(:reject!)
      ContactRequest.should_receive(:find).with('2').and_return(req)
      post :reject, :id => 2
    end
  end

end
