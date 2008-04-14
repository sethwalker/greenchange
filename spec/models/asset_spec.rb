require File.dirname(__FILE__) + '/../spec_helper'

describe Asset do
  Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
  Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"

  before do
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
    @asset = Asset.create :uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')
  end

  after do
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(File.dirname(Asset.public_storage))
  end

  it "should have versions for thumbnails" do
    Asset::Version.count.should == 8
  end

  describe "after saving" do
    before do
      @asset.uploaded_data = fixture_file_upload(File.join('files','photos.png'), 'image/png')
      @asset.save
      @version = @asset.versions.first
    end

    it "should save another set of versions for thumbnails" do
      Asset::Version.count.should == 16 
    end

    it "version should be class Asset::Version" do
      @version.should be_a_kind_of(Asset::Version)
    end

    it "should remember the old filename" do
      @version.filename.should == 'image.png'
    end

    it "should remember the old thumbnail filenames" do
      @version.thumbnail_name_for(:small).should == 'image_small.png'
    end

    it "should know the version is an image" do
      @version.should be_image
    end

    it "should look for file in a version folder" do
      @version.full_filename.should == File.join(@asset.full_dirpath, 'versions/1/image.png')
    end

    it "the current asset should have the recently uploaded data" do
      File.read(@asset.full_filename).should == File.read(RAILS_ROOT + '/test/fixtures/files/photos.png')
    end

    it "the version should have the original data" do
      File.read(@version.full_filename).should == File.read(RAILS_ROOT + '/test/fixtures/files/image.png')
    end

    it "version thumbnails should exist" do
      File.exists?(@version.full_filename(:small)).should be_true
    end

    it "asset and version should have the same number of thumbnails" do
      asset_thumbnails = @asset.thumbnails
      version_thumbnails = @version.thumbnails
      version_thumbnails.length.should == asset_thumbnails.length
    end

    [nil, Asset.attachment_options[:thumbnails].keys].flatten.each do |thumb|
      it "version file for #{thumb || 'parent'} should exist in filesystem" do
        File.exists?(@version.full_filename(thumb)).should be_true
      end
    end

    [nil, Asset.attachment_options[:thumbnails].keys].flatten.each do |thumb|
      it "after destroying, version file for #{thumb || 'parent'} should not exist in filesystem" do
        @version.destroy
        File.exists?(@version.full_filename(thumb)).should be_false
      end
    end

    it "after destroying, asset file should not exist in filesystem" do
      @asset.destroy
      File.exists?(@asset.full_dirpath).should be_false
    end
  end

  #XXX:warning, extremely brittle test
  it "should use file_storage" do
    @asset = Asset.new :filename => 'image.jpg'
    @asset.full_filename.should match(/#{Asset.file_storage}\/\d{4}\/\d{4}\/#{@asset.filename}/)
  end
  
  it "should be public" do
    @asset.should be_public
  end

  it "after updating access when public, should make a symlink" do
    @asset.update_access
    File.exists?(@asset.public_dirpath).should be_true
  end
  
  it "after updating access when not public, should not have a symlink" do
    @asset.update_access
    @asset.should_receive(:public?).and_return(false)
    @asset.update_access
    File.exists?(@asset.public_dirpath).should be_false
  end

  it "should remove file when asset is destroyed" do
    @asset.destroy
    File.exists?(@asset.full_filename).should be_false
  end

  it "should remove symlink when asset is destroyed" do
    File.exists?(@asset.public_dirpath).should be_false
  end
end


describe Asset, "when updating" do
#  fixtures :assets
  before(:all) do
    @old_file_storage = Asset.file_storage
    @old_public_storage = Asset.public_storage
    Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
    Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"
  end
  after(:all) do
    Asset.file_storage = @old_file_storage
    Asset.public_storage = @old_public_storage
  end
  before do
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
    @asset = Asset.new :uploaded_data => ActionController::TestUploadedFile.new(asset_fixture_path('gears.jpg'), 'image/jpg')
  end
  after do
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(Asset.public_storage)
  end

  it "should update attachment filename when saving a new version" do
    @asset.save
    old_version = @asset.version
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')
    @asset.save
    File.basename(@asset.filename).should == 'gears2.jpg'
    File.basename(@asset.versions.first.filename).should == 'gears.jpg'
  end

  it "should copy attachment data when saving a new version" do
    @asset.save
    @asset.uploaded_data = ActionController::TestUploadedFile.new(asset_fixture_path('image.png'), 'image/png')
    @asset.save
    File.read(@asset.full_filename).should == File.read(asset_fixture_path('image.png'))
    File.read(@asset.versions.first.full_filename).should == File.read(asset_fixture_path('gears.jpg'))
    File.read(@asset.full_filename).should_not == File.read(@asset.versions.first.full_filename)
  end

  it "should remember old filename when it's time to copy asset" do
    @asset.save
    lambda {
    @asset.update_attribute(:uploaded_data, ActionController::TestUploadedFile.new(asset_fixture_path('gears2.jpg'), 'image/jpg')) #uploaded_data= + save
    }.should_not raise_error
  end
end

describe Asset do
  before do
    @asset = Asset.new
  end
  it "should respond to image?" do
    @asset.should respond_to(:image?)
  end
  it "should respond to audio?" do
    @asset.should respond_to(:audio?)
  end
  it "should respond to video?" do
    @asset.should respond_to(:video?)
  end
  it "should respond to document?" do
    @asset.should respond_to(:document?)
  end
end
