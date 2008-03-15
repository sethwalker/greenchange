require File.dirname(__FILE__) + '/../spec_helper'

describe AssetObserver do
  Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
  Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"

  before do
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
  end

  after do
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(File.dirname(Asset.public_storage))
  end

  it "is called when the asset saves" do
    @observer = AssetObserver.instance
    @observer.should_receive(:after_save).exactly(Asset.attachment_options[:thumbnails].length + 1).times
    create_asset
  end

  it "should update the page type in the database when the asset saves" do
    @asset = create_asset
    @page = Tool::Asset.create :title => 'asset', :data => @asset
    @asset.save
    Page.find(@page.id).should be_a_kind_of(Tool::Image)
  end
end
