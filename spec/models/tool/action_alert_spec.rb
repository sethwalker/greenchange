require File.dirname(__FILE__) + '/../../spec_helper'

if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else
  describe Tool::ActionAlert, "with sphinx" do
    self.use_transactional_fixtures=false
    before do
      Tool::ActionAlert.destroy_all
      @bystander = create_page :title => 'mofo time' 
      @page = Tool::ActionAlert.create!(:title => 'searchable', :page_data => { :body => 'should have seen this one, mofo' } )
    end

    it "finds by content" do
      reindex
      Tool::ActionAlert.search('mofo').should include(@page)
    end

    it "does not find non-matching bystanders" do
      reindex
      Tool::ActionAlert.search('mofo').should_not include(@bystander)
    end
  end
end
  

