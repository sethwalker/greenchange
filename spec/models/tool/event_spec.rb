require File.dirname(__FILE__) + '/../../spec_helper'

if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else
  describe Tool::Event, "with sphinx" do
    self.use_transactional_fixtures=false
    before do
      Tool::Event.destroy_all
      @bystander = create_page :title => 'mofo time' 
      @page = Tool::Event.new :title => 'searchable', :starts_at => 1.week.from_now, :ends_at => 2.weeks.from_now
      @event = @page.build_data :description => 'should have seen this one, mofo', :city => 'Flint', :state => 'Michigan' 
      @event.page = @page
      @page.save!
    end

    it "finds by description content" do
      reindex('tool_event_core tool_event_delta')
      Tool::Event.search('mofo').should include(@page)
    end

    it "finds by city content" do
      reindex('tool_event_core tool_event_delta')
      Tool::Event.search('flint').should include(@page)
    end

    it "finds by state content" do
      reindex('tool_event_core tool_event_delta')
      Tool::Event.search('michigan').should include(@page)
    end

    it "does not find non-matching bystanders" do
      reindex('tool_event_core tool_event_delta')
      Tool::Event.search('mofo').should_not include(@bystander)
    end
  end
end
