require File.dirname(__FILE__) + '/../spec_helper'

describe Contact do

  describe "on creation" do
    before do
      @a = create_user
      @b = create_user
      @a.contacts << @b
    end
    it "should create a reciprocal relationship" do
      @b.contacts(true).should include(@a)
    end
    it "should validate that no relationship already exists" do
      new_contact = Contact.create :contact =>  @b, :user => @a
      new_contact.should_not be_valid
    end
    it "should not create extra contact records" do
      lambda { @a.contacts << @b }.should raise_error
      @a.contacts(true)
      @a.contacts.size.should == 1
    end
  end

  describe "on removal" do
    before do
      @a = create_user
      @b = create_user
      @a.contacts << @b
      @a.save
      @ab_rel = @a.contact_relationships.find :first, :conditions => [ 'contact_id = ?',  @b ]
      @ab_rel.destroy if @ab_rel
    end

    it "should remove the reciprocal relationship" do
      @b.contacts.should_not include(@a)
    end
  end

end
