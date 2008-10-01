class Tool::WikiController < Tool::BaseController
  include HTMLDiff

  def update
    @page = page_class.find( params[:id] )

    if params[:cancel] && @page.data && @page.data.editable_by?( current_user )
      @page.data.unlock  
      redirect_to tool_page_url(@page) and return
    end

    @page.data.updater = current_user if @page.data

    begin
      @page.updated_by = current_user
      super
    rescue RecordLockedError => e
      flash.now[:error] = e.message
      render :action => 'edit'
    end
  end
  
  def version
    @version = @wiki.versions.find_by_version(params[:version])
  end

  def versions
    render :template => "/tool/wiki/versions"
  end
  
  def diff
    old_id = params[:from]
    new_id = params[:to]
    @old = @wiki.versions.find_by_version(old_id)
    @new = @wiki.versions.find_by_version(new_id)
    @old_markup = @old.body_html || ''
    @new_markup = @new.body_html || ''
    @difftext = html_diff( @old_markup , @new_markup)
  end
  
  def preview
    # not yet
  end
  
  def break_lock
    @page = page_class.find(params[:id])
    @page.data.unlock
    redirect_to wiki_url(@page)
  end
    
  protected
  
  def save_edits
    @wiki = @page.data || @page.build_data
    if @wiki.version > params[:data][:version].to_i
      message :error => "can't save your data, someone else has saved new changes first."
      return false
    elsif not @wiki.editable_by? current_user
      message :error => "can't save your data, someone else has locked the page."
      return false
    end
    begin
      @wiki.body = params[:data][:body]
      if save_revision(@wiki)
        @page.updated_by = current_user
        @page.save
        @wiki.unlock
        return true
      else
        message :object  => @wiki
      end
    rescue ActiveRecord::StaleObjectError
      # this exception is created by optimistic locking. 
      # it means that @wiki has change since we fetched it from the database
      message :error => "locking error. can't save your data, someone else has saved new changes first."
    end
    return false
  end
  
  # save the wiki, and make a new version only if the last
  # version was not recently saved by current_user
  def save_revision(wiki)
    if wiki.recent_edit_by?(current_user)
      wiki.save_without_revision
      wiki.versions.find_by_version(wiki.version).update_attributes(:body => wiki.body, :body_html => wiki.body_html)
    else
      wiki.user = current_user
      wiki.save
    end  
  end
  
  def fetch_wiki
    @wiki = @page.data 
  end
  
  def setup_view
  end
  
end

