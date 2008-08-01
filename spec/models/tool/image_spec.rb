require File.dirname(__FILE__) + '/../../spec_helper'

if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else
  describe Tool::Image, "with sphinx" do
    self.use_transactional_fixtures=false
    Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
    Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"
    before do
      Tool::Image.delete_all
      FileUtils.mkdir_p(Asset.file_storage)
      FileUtils.mkdir_p(Asset.public_storage)
      @bystander = new_page :title => 'mofo time'
      @bystander.type = 'Tool::Image'
      @bystander.save
      @page = Tool::Image.create!(:title => 'mofo', :page_data => { :uploaded_data => fixture_file_upload(File.join('files', 'photos.png'), 'image/png') } )
    end

    after do
      FileUtils.rm_rf(Asset.file_storage)
      FileUtils.rm_rf(File.dirname(Asset.public_storage))
    end

    it "finds by content" do
      reindex
      Tool::Image.search('mofo').should include(@page)
    end

    it "does not find non-matching bystanders" do
      reindex
      Tool::Image.search('mofo').should_not include(@bystander)
    end
  end
end
  

