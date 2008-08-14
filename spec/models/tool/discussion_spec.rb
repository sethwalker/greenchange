require File.dirname(__FILE__) + '/../../spec_helper'

if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else
  describe Tool::Discussion, "with sphinx" do
    self.use_transactional_fixtures=false
    before do
      Tool::Discussion.destroy_all
      @bystander = create_page :title => 'mofo time' 
      @bystander.type = 'Tool::Discussion'
      @bystander.save
      @page = Tool::Discussion.create!(:title => 'searchable' , :page_data => { :new_post => {:body => 'should have seen this one, mofo', :user_id => create_user.id } }  )
    end

    it "finds by content" do
      reindex('tool_discussion_core tool_discussion_delta')
      Tool::Discussion.search('mofo').should include(@page)
    end

#    it "does not find non-matching bystanders" do
#      reindex('tool_discussion_core tool_discussion_delta')
#      Tool::Discussion.search('mofo').should_not include(@bystander)
#    end
  end

=begin
  describe "with a delta index" do
    self.use_transactional_fixtures=false
    before do
      ThinkingSphinx.deltas_enabled = true
      ThinkingSphinx.updates_enabled = true
      Tool::Discussion.destroy_all
      @bystander = create_page :title => 'mofo time' 
      @bystander.type = 'Tool::Discussion'
      @bystander.save
      @page = Tool::Discussion.create!(:title => 'searchable' , :page_data => { :new_post => {:body => 'should have seen this one, mofo', :user_id => create_user.id } }  )
    end
    after do
      ThinkingSphinx.deltas_enabled = false
      ThinkingSphinx.updates_enabled = false
    end

    it "should find" do
      reindex
      @page.title = 'the new hotness'
      @page.save!
      sleep(1.5)
      Tool::Discussion.search('hotness').should include(@page)
    end

    it "finds by new posts" do
      pending do
      reindex
      @post = @page.build_post Post.new(:body => 'watch your language, fartwad'), create_user
      @post.save!
      sleep(1)
      Tool::Discussion.search('fartwad').should include(@page)
      end
    end
  end
=end
end
