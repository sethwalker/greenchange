describe "message creation", :shared => true  do
  before do
    @message_params = { :body => 'chu', :recipients => 'joey, frankie' }
  end
  def act!
    post :create, object_name => @message_params
  end
  it "creates new messages with spawn" do
    current_model.should_receive(:spawn).and_return([current_model.new])
    act!
  end

  it "assigns a messages array" do
    act!
    assigns[objects_collection].should_not be_empty
  end
  it "assigns a new blank message" do
    spawn_returns([Message.new, Message.new])
    act!
    assigns[object_name].should_not be_nil
  end

  it "assigns invalid messages for later handling" do
    spawn_returns([Message.new, Message.new, Message.create( :sender => create_user, :recipient => create_user ) ])
    act!
    assigns[invalid_objects_collection].size.should == 2
  end

  it "targets invalid recipients in the message error" do
    spawn_returns([ Message.new, Message.new( :recipients => 'invalid' ), Message.new( :sender => create_user, :recipient => User.new, :recipients => 'invalid' ) ] )
    act!
    assigns[object_name].errors.should_not be_empty
    assigns[object_name].errors.any?{ |e| e.last =~ /couldn.t send/}.should be_true
  end

  it "recognizes valid messages and saves them" do
    valid_message = Message.create( :sender => create_user, :recipient => create_user ) 
    spawn_returns([Message.new, Message.new, valid_message ] )
    valid_message.should_receive(:save)
    act!
  end

  def spawn_returns(values)
    current_model.stub!(:spawn).and_return values
  end
end

describe "message destruction", :shared => true  do
  before do
    request.env["HTTP_REFERER"] = "/me/inbox"
    @message = current_model.new :sender => create_user
    @message.stub!(:allows?).and_return true
    current_model.stub!(:find).and_return @message
  end
  def act!
    delete :destroy, :id => 1
  end
  it "checks permissions" do
    @message.should_receive(:allows?)
    act!
  end
  it "deletes messages" do
    @message.should_receive(:destroy)
    act!
  end
  it "deletes messages" do
    act!
    @response.should redirect_to('/me/inbox')
  end
end
