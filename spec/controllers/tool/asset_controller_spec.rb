require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::AssetController do
  it "should keep the page title as the filename for new versions" do
    @asset = Asset.new :filename => 'pagetitle.gif'
    @page = stub_everything
    @page.stub!(:data).and_return(@asset)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:fetch_page_data).and_return(true)
    controller.instance_variable_set(:@page, @page)
    @page.stub!(:title).and_return('pagetitle')
    @asset.filename = 'pagetitle.gif'

    post 'update', {:asset => ActionController::TestUploadedFile.new(asset_fixture_path('gears.jpg'), 'image/jpg')}
    response.should be_redirect
    @asset.filename.should == 'pagetitle.jpg'
  end

  describe "new" do
    before do
      login_valid_user
    end
    it 'should be successful' do
      get :new
      response.should be_success
    end
  end

  describe "create" do
    before do
      login_valid_user
    end
    it 'should be successful' do
      post :create, :page => {:title => 'assetpage'}, :asset => {:filename => 'file.jpg'}
      response.should be_success
    end
  end

  describe "update" do
    before do
      login_valid_user
      @page = create_page(:type => 'Tool::Asset', :data => create_asset)
    end
    it 'should be successful' do
      controller.stub!(:authorized?).and_return(true)
      Page.should_receive(:find).with(@page.to_param).and_return(@page)
      put :update, :id => @page.to_param
      response.redirect_url.should == upload_url(@page)
    end
  end

  describe "destroy_version" do
    before do
      login_valid_user
      @page = create_page(:type => 'Tool::Asset', :data => create_asset)
    end
    it 'should be successful' do
      controller.stub!(:authorized?).and_return(true)
      delete :destroy_version, :id => @page.to_param, :version => 1
      response.redirect_url.should == upload_url(@page)
    end
  end

  describe "routes" do
    before do
      get :new
      User.current = nil
    end
    it "should recognize upload_url" do
      new_upload_path.should == '/uploads/new'
    end
    it "should recognize destroy_version_upload_path" do
      page = Tool::Asset.create(:title => 'asset')
      destroy_version_upload_path(page, :version => 1).should == "/uploads/#{page.to_param}/destroy_version?version=1"
    end
  end
end
