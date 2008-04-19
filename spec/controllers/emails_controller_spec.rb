require File.dirname(__FILE__) + '/../spec_helper'

describe EmailsController do
  before do
    @email_recipient = EmailRecipient.create :email => 'jack@strop.com'
    EmailRecipient.stub!(:find_by_retrieval_code).and_return(@email_recipient)
  end
  def act!
    get :block, :id => @email_recipient.id
  end
  it "calls block on the recipient" do  
    @email_recipient.should_receive(:block!)
    act!
  end


end

