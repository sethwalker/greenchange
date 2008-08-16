require File.dirname(__FILE__) + '/../spec_helper'

describe "SocialUser" do

  #fixtures :users, :groups, :memberships, :pages

  before do
    #TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
    @user = create_user
    @group = create_group
  end

  it "should be mixed into user" do
   @user.is_a?(SocialUser).should be_true
  end

  describe "in group memberships" do
    it "should add users when a membership is added" do
      lambda{ @group.memberships.create :user => @user }.should change( @group.users, :count ).by(1)
      # @user.memberships.create :group => @group (another valid way to do the same thing)
      #assert oldcount < @group.users.count, "group should have more users after add user"   
    end
    describe "already existing" do 
      before do
        @group.memberships.create :user => @user
      end

      it "finds the user" do
        @group.users.find(@user.id).should == @user
      end

      it "finds the group" do
        @user.groups.find(@group.id).should == @group
      end

      it "knows its membership status" do
        @user.should be_member_of(@group)
      end

      it "notices when membership ends" do
        @user.groups.delete @group
        @user.should_not be_member_of(@group)
      end
  
      it "does not allow duplicate memberships" do
        lambda { @user.memberships.create :group => @group }.should raise_error(ActiveRecord::StatementInvalid)
      end
    end

    describe "membership data #no longer caches ids" do

      before do
        @user = create_user
        @group = create_group
        @group.memberships.create :user => @user
      end

      it "should have a group ids array" do
        @user.group_ids.should == [@group.id]
      end

      it "should include group in all groups array" do
        @user.all_group_ids.should == [@group.id]
      end

      it "serialize_as the all_group_ids to a cache" do
        group2 = create_group
        group2.memberships.create :user => @user
        @user.all_group_id_cache.should == [@group.id, group2.id]
      end

      it "should update groups array when changes happen" do
        user = create_user
        user.groups #performs initial caching
        group = create_group
        group.memberships.create :user => user
        user.group_ids.should == [ group.id ]
      end
      it "should update the all-groups array when changes happen" do
        user = create_user
        user.all_groups #performs initial caching
        group = create_group
        group.memberships.create :user => user
        #user.all_groups(true) #reloads associations
        user.all_group_ids.should == [ group.id ]
      end

    end
      
  end

  describe "when having contacts" do
    before do
      @a = create_user
      @b = create_user
    end

    it "starts without contacts" do
      @a.contacts.should_not include(@b)
    end

    it "accepts << contacts" do
      @a.contacts << @b
      @a.contacts.should include(@b)
    end

    describe "that already exist" do
      before do
        @a.contacts << @b
      end
      it "adds contacts to the friend id cache" do
        @a.reload
        @a.friend_id_cache.should include(@b.id)
      end
      it "notices deletion" do
        @a.contacts.delete(@b)
        @a.contacts.should_not include(@b)
      end

    end
  end

  describe "with committees" do
    before do
      @user = create_user

      @group = create_group
      @group.memberships.create :user => @user
      @committee = Committee.create :name => 'dumbledores-army', :parent => @group
      @user.reload
    end
    it "group member automatically has committee in all_groups collection" do
      @user.all_group_ids.sort.should == [@group.id, @committee.id].sort
    end
  end


  describe "when pestering," do
    before do
      @user1 = create_user
      @user2 = create_user
    end
    it "does not allows pestering by strangers" do
      @user1.may_pester?(@user2).should be_false
      #@user2.may_be_pestered_by?(@user1).should be_true
    end
    it "only allows pestering by contacts" do
      @user1.contacts << @user2
      @user1.may_pester?(@user2).should be_true
    end
    it "groups may be pestered by all" do
      @group = create_group
      @user1.may_pester?(@group).should be_true
    end
    it "pestering can be stopped" do
      pending "pestering is still globally allowed to contacts ( no ban list )" 
    end
  end

  describe "with pages" do
    it "should be able to access pending pages" do
      p = create_page
      @user.pages << p
      @user.participations.detect {|up| up.page_id = p.id }.update_attribute :resolved, false
      @user.pages_pending.should include(p)
    end

  end
    
end

