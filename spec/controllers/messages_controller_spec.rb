require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/messages_spec_helper'


describe MessagesController do
  before do
    login_user(@user = create_user)
    @message = Message.new :sender => create_user
    Message.stub!(:find).and_return(@message)
  end
  describe "MessagesController GET show" do
    def act!
      get :show, :id => 1
    end
    it "checks for permission" do
      @message.should_receive(:allows?)
      act!
    end
  end


  describe "POST create" do
    it_should_behave_like "message creation"
    def current_model; Message; end
    def object_name; :message; end
    def objects_collection; :messages; end
    def invalid_objects_collection; :invalid_messages; end
  end

  describe "GET new" do
    before do
      @request_attr = {}
    end

    def act!
      get :new, @request_attr
    end
    it "assigns @person as the recipient if there's a person_id in the request" do
      @request_attr = { :person_id => ( recipient_id = create_user.id ) }
      act!
      assigns[:message].recipient_id == recipient_id
    end
  end

  describe "GET index" do
    before do
      @message_proxy = [ Message.new ]
      @message_proxy.stub!(:find)
      @request_attr = {}
    end
    def act!
      get :index, @request_attr
    end

    it "assigns messages" do
      act!
      assigns[:messages].should_not be_nil
    end

    it "gets received messages by default" do
      Message.should_receive(:to).and_return @message_proxy
      act!
    end

    it "gets sent messages when asked" do
      @request_attr = { :message_action => 'sent' }
      Message.should_receive(:from).and_return @message_proxy
      act!
    end
  end

  describe "DELETE destroy" do
    def current_model; Message; end
    def act!
      delete :destroy, :id => 1 
    end
    it "is told to ignore the message" do
      Message.stub!(:find).and_return(@message)
      @user.stub!(:may!).and_return(true)
      @message.should_receive( :update_attribute).with( :state, 'deleted')
      controller.stub!(:redirect_to)
      act!
    end
  end
end
