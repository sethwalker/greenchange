require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared'

describe "an unsuccessful update", :shared => true do
  it "should render edit" do
    act!
    response.should be_success
    response.should render_template('tool/wiki/edit')
  end
  it "should not have saved the page" do
    act!
    Page.find(@page).title.should == 'awiki'
  end
  it "should not have saved the wiki" do
    act!
    Wiki.find(@wiki).body.should == 'oldbody'
  end
end

describe Tool::WikiController do
#  it_should_behave_like "a tool controller"

  before do
    @user = login_valid_user
    controller.stub!(:fetch_page_data)
    controller.stub!(:fetch_wiki)
    #now jump thru some hoops to get the page type we want while still using fixture_replacement
    @page = new_page(:type => 'Tool::TextDoc', :title => 'awiki')
    @page.type = 'Tool::TextDoc'
    @page.save
    @page = Page.find(@page)
    @wiki = Wiki.new
    controller.instance_variable_set(:@page, @page)
    controller.instance_variable_set(:@wiki, @wiki)
    controller.stub!(:login_or_public_page_required).and_return(true)
    controller.stub!(:authorized?).and_return(true)
  end
  describe "show" do
    it "should be successful" do
      @wiki.should_receive(:version).and_return(2)
      get :show, :id => @page
      response.should be_success
    end
    it "should redirect if no version" do
      @wiki.should_receive(:version).and_return(0)
      get :show, :id => @page
      response.redirect_url.should == edit_wiki_url(@page)
    end
  end
  describe "edit" do
    it "should call lock" do
      @wiki.should_receive(:lock)
      get :edit, :id => @wiki.to_param
    end
  end
  describe "diff route" do
    it "should be named" do
      get :show, :id => @page #hack to set up controller
      diff_wiki_path(@page, :from => '2', :to => '3').should == "/wikis/#{@page.to_param}/diff?from=2&to=3"
    end
  end
  describe "break_lock route" do
    it "should recognize" do
      params_from(:post, "/wikis/#{@page.to_param}/break_lock").should == {:controller => 'tool/wiki', :action => 'break_lock', :id => @page.to_param}
    end
  end
  describe "new" do
    it "should set @page" do
      get :new
      assigns[:page].should be_a_kind_of(Tool::TextDoc)
    end
    it "should set @wiki" do
      get :new
      assigns[:wiki].should be_a_kind_of(Wiki)
    end
  end
  describe "create" do
    before do
      post :create, :page => {:title => 'thetitle'}, :data => {:body => "thebody"}
    end
    it "should create page" do
      assigns[:page].should be_valid
    end
    it "should create wiki" do
      assigns[:page].data.body.should == 'thebody'
    end
  end
  describe "update" do
    before do
      @wiki.body = "oldbody"
      @wiki.page = @page
      @wiki.save
      @page.stub!(:data).and_return(@wiki)
    end
    describe "with valid params" do
      before do
        put :update, :id => @page.to_param, :page => {:title => 'updated'}, :data => {:body => 'newbody', :version => @wiki.version}
      end
      it "should redirect to wiki show" do
        response.should be_redirect
      end
    end

    describe "with old lock version" do
      it_should_behave_like "an unsuccessful update"

      def act!
        put :update, :id => @page.to_param, :page => {:title => 'updated'}, :data => {:body => 'newbody', :version => @wiki.version - 1} 
      end

      it "should show a message" do
        controller.__send__(:flash).should_receive(:now).and_return(mock_now = mock('now'))
        mock_now.should_receive(:[]=).with(:error, /saved new changes first/)
        act!
      end
    end

    describe "without being locked" do
      def act!
        put :update, :id => @page.to_param, :page => {:title => 'updated'}, :data => {:body => 'newbody', :version => @wiki.version}
      end
      describe "when save fails" do
        before do
          @wiki.should_receive(:recent_edit_by?).and_return(false)
          @wiki.should_receive(:save).and_return(false)
        end
        it_should_behave_like "an unsuccessful update"

        it "should message the object" do
          controller.should_receive(:message).with({:object => @wiki})
          act!
        end
      end

      describe "recent edit update success" do
        before do
          @wiki.stub!(:recent_edit_by?).and_return(true)
          @old_version_number = @wiki.version
          @old_version = @wiki.versions.find_by_version(@wiki.version)
          @old_version_updated_at = 1.day.ago
          @old_version.class.update_all("updated_at = '#{@old_version_updated_at.to_s(:db)}'", "id = #{@old_version.id}")
          act!
        end
        it "should be successful" do
          response.should be_redirect
        end
        it "should redirect do show" do
          response.redirect_url.should == wiki_url(@page)
        end
        it "should keep the same version number" do
          Wiki.find(@wiki).version.should == @old_version_number
        end
        it "should update the wiki" do
          Wiki.find(@wiki).body.should == 'newbody'
        end
        it "should update the version" do
          Wiki.find(@wiki).versions.find_by_version(@wiki.version).body.should == 'newbody'
        end
        it "should set updated_at" do
          Wiki.find(@wiki).versions.find_by_version(@wiki.version).updated_at.should > @old_version_updated_at
        end
      end

      describe "no recent edit update success" do
        before do
          @wiki.stub!(:recent_edit_by?).and_return(false)
          @old_version_number = @wiki.version
          act!
        end
        it "should be successful" do
          response.should be_redirect
        end
        it "should redirect do show" do
          response.redirect_url.should == wiki_url(@page)
        end
        it "should save the wiki" do
          Wiki.find(@wiki).body.should == 'newbody'
        end
        it "should up the revision" do
          Wiki.find(@wiki).version.should == @old_version_number + 1
        end
        it "should not have updated the old version" do
          Wiki.find(@wiki).versions.find_by_version(@old_version_number).body.should == 'oldbody'
        end
      end
    end

    describe "without being able to edit because i didn't lock it" do
      before do
        @wiki.stub!(:locked?).and_return(true)
        @wiki.stub!(:locked_by).and_return(User.new)
      end

      it_should_behave_like "an unsuccessful update"

      def act!
        put :update, :id => @page.to_param, :page => {:title => 'updated'}, :data => {:body => 'newbody', :version => @wiki.version} 
      end

      it "should show a message" do
        controller.__send__(:flash).should_receive(:now).and_return(mock_now = mock('now'))
        mock_now.should_receive(:[]=).with(:error, /someone else has locked the page/)
        act!
      end
    end

    it "should call save_edits" do
      controller.should_receive(:save_edits)
      put :update, :id => @page.to_param
    end
    describe "when canceling" do
      it "should unlock" do
        @wiki.should_receive(:unlock)
        put :update, :id => @page.to_param, :cancel => true
      end
      it "should redirect to wiki url" do
        put :update, :id => @page.to_param, :cancel => true
        response.redirect_url.should == wiki_url(@page)
      end
    end
  end
end
