require File.dirname(__FILE__) + '/../../spec_helper'

if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else
  describe Tool::Discussion, "with sphinx" do
    self.use_transactional_fixtures=false
    before do
      Tool::Discussion.destroy_all
      @bystander = create_page :title => 'mofo time' 
      @page = Tool::Discussion.create!(:title => 'searchable' , :page_data => { :new_post => {:body => 'should have seen this one, mofo', :user_id => create_user.id } }  )
    end

    it "finds by content" do
      reindex
      Tool::Discussion.search('mofo').should include(@page)
    end

    it "does not find non-matching bystanders" do
      reindex
      Tool::Discussion.search('mofo').should_not include(@bystander)
    end
  end
end
