class Tool::ActionAlertController < Tool::WikiController
  append_before_filter :fetch_wiki
  helper FormHelper
  
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
      save_meta @action_alert
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
  
  # save the wiki, and make a new version only if the last
  # version was not recently saved by current_user
  def save_revision(wiki)
    if wiki.recent_edit_by?(current_user)
      wiki.save_without_revision
      wiki.find_version(wiki.version).update_attributes(:body => wiki.body, :body_html => wiki.body_html, :updated_at => Time.now)
    else
      wiki.user = current_user
      wiki.save
    end  
  end
  
  def fetch_wiki
    return true unless @page
    @page.data ||= ActionAlert.new(:body => 'new page', :page => @page)
    logger.debug( '###' + @page.data.id.to_s)
    @action_alert = @wiki = @page.data
  end
  
end

