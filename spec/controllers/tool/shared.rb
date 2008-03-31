describe "a tool controller", :shared => true do
  describe "create" do
    before do
      login_valid_user
      @war = create_issue :name => 'war'
      @peace = create_issue :name => 'peace'
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
  end
end
