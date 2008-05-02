require File.dirname(__FILE__) + '/../spec_helper'

describe "DocumentMetaData module" do
  before(:all) do
    unless Wiki.ancestors.include? DocumentMetaData
      class Wiki < ActiveRecord::Base; include DocumentMetaData; end
    end
  end
  before do
    @resource = Wiki.create :body => 'blah'
  end

  describe "with existing metadata" do
    before do
      @meta = DocumentMeta.create :creator => "Scott Baio", :source => 'Charles in Charge'
      @resource.document_meta = @meta
    end

    it "should call save on the metadata after save" do
      @meta.should_receive(:save).and_return true
      @resource.save
    end 

    it "should return the existing metadata" do
      @resource.document_meta_data.should == @meta
    end

    it "should override with a partial assignment hash" do
      @resource.document_meta_data = { :creator => 'joe' }
      @resource.document_meta_data.creator.should == 'joe'
      @resource.document_meta_data.source.should match(/Charles/)
    end
  end

  describe "with no metadata" do
    it "should offer a blank metadata" do
      @resource.document_meta_data.should be_an_instance_of(DocumentMeta)
    end
    it "should accept an assignment hash" do
      @resource.document_meta_data = { :creator => 'joe', :source => 'jaime' }
      @resource.document_meta_data.creator.should == 'joe'
    end
  end

   
end
