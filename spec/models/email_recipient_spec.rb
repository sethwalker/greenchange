require File.dirname(__FILE__) + '/../spec_helper'

describe EmailRecipient do
  before do
    @recipient = EmailRecipient.new
  end
  it "is blocked when told to be blocked" do
    @recipient.block!
    @recipient.should be_blocked
  end
  it "is not blocked by default" do
    @recipient.should_not be_blocked
  end

  it "creates a retrieval code on save" do
    @recipient.email = 'jo@jo.com'
    @recipient.save.should be_true
    @recipient.retrieval_code.should_not be_nil
  end
end
