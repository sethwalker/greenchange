require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::Asset do
  before do
    @p = Tool::Asset.new
  end
  it "should respond to image?" do
    @p.should respond_to(:image?)
  end
  it "should respond to audio?" do
    @p.should respond_to(:audio?)
  end
  it "should respond to video?" do
    @p.should respond_to(:video?)
  end
  it "should respond to document?" do
    @p.should respond_to(:document?)
  end
  it "should update type if content type changes" do
  end
end
if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else
  describe Tool::Asset, "with sphinx" do
    self.use_transactional_fixtures=false
    Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
    Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"
    before do
      Tool::Asset.destroy_all
      FileUtils.mkdir_p(Asset.file_storage)
      FileUtils.mkdir_p(Asset.public_storage)
      @bystander = create_page :title => 'mofo time' 
      @page = Tool::Asset.create!(:title => 'searchable', :page_data => { :uploaded_data => fixture_file_upload(File.join('files','photos.png'), 'image/png') } )
    end

    after do
      FileUtils.rm_rf(Asset.file_storage)
      FileUtils.rm_rf(File.dirname(Asset.public_storage))
    end

    it "finds by content" do
      pending "setup asset search"
      reindex
      Tool::Asset.search('image/png').should include(@page)
    end

  end
end
