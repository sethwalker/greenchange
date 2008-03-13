require File.dirname(__FILE__) + '/../spec_helper'

describe Tagging do
  before do
    @page1 = create_page
    @page2 = create_page
  end

  it "should set tags" do
    @page2.tag_with "hoppy pilsner"
    @page2.tag_list.should == "hoppy pilsner"
  end

  it "should set tags with array" do
    @page2.tag_with ["lager", "stout", "fruity", "seasonal"]
    @page2.tag_list.should == "fruity lager seasonal stout"
  end
  
  describe "after adding tags" do
    before do
      @page1.tag_with "seasonal lager ipa"
      @page2.tag_with ["lager", "stout", "fruity", "seasonal"]
      @result1 = [@page1]
      @result2 = [@page1.id, @page2.id].sort
    end

    it "should find tagged pages with tagged_with a tag" do
      Page.tagged_with("ipa").to_a.should == @result1
    end

    it "should find pages tagged with space separated list" do
      Page.tagged_with("ipa lager").to_a.should == @result1
    end

    it "should find pages by array" do
      Page.tagged_with("ipa", "lager").to_a.should == @result1
    end
      
    it "should find all pages with a tag" do
      Page.tagged_with("seasonal").map(&:id).sort.should == @result2
    end

    it "should find all pages with a space separated list" do
      Page.tagged_with("seasonal lager").map(&:id).sort.should == @result2
    end

    it "should find all pages by array of tags" do
      Page.tagged_with("seasonal", "lager").map(&:id).sort.should == @result2
    end
  end
    
  describe "internal methods" do

    before do
      @page1.tag_with("pale")
      @page2.tag_with("pale imperial")
      @tag1 = Tag.find(1)  
    end

    it "should add tags with _add_tags" do
      @page1._add_tags "porter longneck"
      Tag.find_by_name("porter").taggables.should include(@page1)
    end

    it "should add tags with _add_tags" do
      @page1._add_tags "porter longneck"
      Tag.find_by_name("longneck").taggables.should include(@page1)
    end

    it "should add tags with _add_tags" do
      @page1._add_tags "porter longneck"
      @page1.tag_list.should == "longneck pale porter"
    end

    it "should add tags with _add_tags by id" do
      @page1._add_tags "porter longneck"
      @page1._add_tags [2]
      @page1.tag_list.should == "imperial longneck pale porter"
    end
    
    it "should remove tags with _remove_tags" do
      @page2._remove_tags ["2", @tag1]
      @page2.tags.should be_empty
    end
  end
      
  it "should not be taggable" do
    tagging = new_tagging
    tagging.save
    tagging.send(:taggable?).should be_false
  end

  it "should raise an error on taggable if raise error flag is true" do
    tagging = create_tagging
    lambda { tagging.send(:taggable?, true) }.should raise_error(RuntimeError)
  end
end
