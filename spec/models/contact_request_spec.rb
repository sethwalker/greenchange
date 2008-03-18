require File.dirname(__FILE__) + '/../spec_helper'

describe ContactRequest do
  before do
    @c = ContactRequest.create
  end
  it "should be approvable" do
    @c.approve!
    @c.should be_approved
  end
  it "calls after_approved when we approve" do
    @c.should_receive(:after_approved)
    @c.approve!
  end
  it "creates a Contact" do
    @c.user_id = 2
    @c.contact_id = 3
    @c.approve!
    Contact.find_by_user_id_and_contact_id(2,3).should_not be_nil
  end
end
