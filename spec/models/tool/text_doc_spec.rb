require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::TextDoc do

  before do
    @page = Tool::TextDoc.new :title => 'new'
  end

  describe "when creating" do
    before do
      @page = Tool::TextDoc.new :title => 'new', :page_data => {:body => 'wikibody'}
      @page.save
    end
    it "should save the wiki" do
      @page.data.should_not be_new_record
    end
    it "should know the data id" do
      @page.data_id.should_not be_nil
    end
    it "should remember the data id" do
      @page.reload.data_id.should_not be_nil
    end
  end

  describe "when updating" do
    before do
      @page.save
    end
    describe "with an associated wiki" do
      self.use_transactional_fixtures = false
      before do
        @page.create_data :body => 'new body'
      end
      it "should be able to update associated data" do
        @page.update_attributes :title => 'updated-title', :page_data => {:body => 'updated body'}
        @page.data(true).body.should == 'updated body'
      end
      it "should raise error if the associated data does not save" do
        lambda { @page.update_attributes :title => 'updated-title', :page_data => {:body => 'updated body', :lock_version => 0} }.should raise_error
      end
      it "should not save if the associated data does not save" do
        begin
          @page.update_attributes :title => 'updated-title', :page_data => {:body => 'updated body', :lock_version => 0}
        rescue RecordLockedError
        end
        Page.find(@page.id).title.should == 'new'
      end
    end
  end
end
