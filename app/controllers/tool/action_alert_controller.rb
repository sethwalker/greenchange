class Tool::ActionAlertController < Tool::WikiController
  append_before_filter :fetch_wiki
  
  def new
    @page = Tool::ActionAlert.new :group_id => params[:group_id]
    @wiki = @page.build_data :body => 'new page'
  end

  def create
    @page = Tool::ActionAlert.new params[:page]
    @page.created_by = current_user
    if @page.save
      if save_edits
        @page.tag_with(params[:tag_list]) if params[:tag_list]
        params[:issues].each do |issue_id|
          @page.issue_identifications.create :issue_id => issue_id
        end
        add_participants!(@page, params)
        redirect_to(action_url(@page))
      else
        render :action => 'new'
      end
    else
      message :object => @page
      render :action => 'new'
    end
  end

  def edit
    @wiki.lock(Time.now, current_user)
    # FIXME this should be automagic?
    @document_meta = @wiki.document_meta
  end

  def update
    if params[:cancel]
      @wiki.unlock
      return redirect_to(action_url(@page))
    end
    save_edits
    redirect_to action_url(@page)
  end

  protected
  
  def save_edits
    begin
      super
      save_meta @wiki
      #@wiki.document_meta.save
    rescue
      raise
    end
  end

  def save_meta(wiki)
    return if params[:document_meta].empty? 
    unless wiki.document_meta.nil? 
      wiki.document_meta.attributes = params[:document_meta]
      return wiki.document_meta.save
    end
    wiki.create_document_meta params[:document_meta]
  end
  
  def fetch_wiki
    return true unless @page
    @page.data ||= ActionAlert.new(:body => 'new page', :page => @page)
    @action_alert = @wiki = @page.data
  end

  def wiki_url(page)
    action_url(page)
  end
  
end

