require File.dirname(__FILE__) + '/../spec_helper'

describe Group do

  before do
    @g = Group.create :name => 'fruits'
  end

  describe "with members" do
    before do
      @u = create_user(:login => 'blue')
    end

    it "should raise an error when using << (WHY???)" do
      lambda { @g.users << @u }.should raise_error
    end

    it "member_of? should return true if member" do
      @g.memberships.create :user => @u, :role => :member
      @u.should be_a_member_of(@g)
    end

    it "should call check_duplicate_memberships when membership is created" do
      @g.should_receive(:check_duplicate_memberships)
      @g.memberships.create :user => @u, :role => :member
    end

    it "should call membership_changed when membership is created" do
      @g.should_receive(:membership_changed)
      @g.memberships.create :user => @u, :role => :member
    end
  end

  it "should require a name" do
    g = Group.create
    g.should have(1).error_on(:name)
  end

  it "should have a unique name" do
    g2 = new_group(:name => 'fruits')
    g2.save
    g2.should have(1).error_on(:name)
  end

  it "should have a name unique to both groups and users" do
    u = create_user
    g = new_group :name => u.login
    g.save
    g.should have(1).error_on(:name)
  end
end
