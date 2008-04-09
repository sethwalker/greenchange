describe "a tool controller", :shared => true do
  before do
    Issue.delete_all
    @user = login_valid_user
    @war = create_issue :name => 'war'
    @peace = create_issue :name => 'peace'
  end
  describe "create with valid params" do
    before do
      post :create, :page => {:title => 'thetitle', :tag_list => "rag tag", :issue_ids => [@war.id, @peace.id]}
    end
    it "should create page" do
      assigns[:page].should be_valid
    end
    it "should assign tags" do
      assigns[:page].tag_list.should =~ /rag/
    end
    it "should assign issues" do
      assigns[:page].issues.should include(@war, @peace)
    end
    it "should save created_by" do
      assigns[:page].created_by.should == @user
    end
  end
  describe "create with invalid params" do
    before do
      post :create, :page => {:title => '', :tag_list => "rag tag", :issue_ids => [@war.id, @peace.id]}
    end
    it "should render the new action" do
      response.should render_template('new')
    end
    it "should have an invalid page" do
      assigns[:page].should_not be_valid
    end
  end
end
