require File.dirname(__FILE__) + '/../spec_helper'

describe Wiki do

  before do
    @blue_user = create_user :login => 'blue'
    @red_user = create_user :login => 'red'
    @group = create_group :name => 'robots'
    @wiki = Tool::TextDoc.create :title => 'x61'
  end

  it "returns the title of the page as the name" do
    @wiki.name.should == 'x61'
  end

  describe "checks uniqueness of names" do
    before do
      @wiki.add @group; @wiki.save
      @new_page = Tool::TextDoc.create :title => 'x61'
      @new_page.add @group;
    end
    it "can confirm the taken? status of a page title" do
      @new_page.name_taken?.should be_true
    end
    
    it "should check uniqueness of names within group" do
      @new_page.should_not be_valid
    end
  end

  describe "locking" do
    before do
      @wiki = Wiki.create :body => 'watermelon'
      @wiki.lock(Time.now, @blue_user )
    end
  
    it "should lock" do
      @wiki.should be_locked
    end
    it "should be editable by the locking user" do
      @wiki.should be_editable_by(@blue_user)
    end
    it "should not be editable by other users" do
      @wiki.should_not be_editable_by(@red_user)
    end

    it "does not allow saving of an expired version" do
      lambda { @wiki.smart_save! :body => 'catelope', :version => -1, :user => @blue_user }.should raise_error
    end
    
    it "does not allow a user without the lock to save" do
      lambda { @wiki.smart_save! :body => 'catelope', :user => @red_user }.should raise_error
    end
      
    it "allows the locking user to save" do
      lambda { @wiki.smart_save! :body => 'catelope', :user => @blue_user }.should_not raise_error
    end

    describe "recent edit" do
      before do
        @wiki.stub!(:editable_by?).and_return(true)
        @wiki.stub!(:updater).and_return(true)
        @wiki.stub!(:recent_edit_by?).and_return(true)
      end
      it "should call save_without_revision" do
        @wiki.should_receive(:save_without_revision)
        @wiki.save
      end
      it "should have the same version number" do
        @wiki.save
        @wiki.version.should == 1
      end
      it "should have the same number of versions" do
        @wiki.save
        @wiki.versions.length.should == 1
      end
      it "should update the version when using save" do
        @wiki.body = 'grapefruit'
        @wiki.save
        @wiki.versions.first.body.should == 'grapefruit'
      end
      it "should update the version when using update_attributes" do
        @wiki.update_attributes :body => 'pineapple'
        @wiki.versions.first.body.should == 'pineapple'
      end
    end
  end
   
end

