class Tool::WikiController < Tool::BaseController
  include HTMLDiff
  append_before_filter :fetch_wiki
  
  stylesheet 'wiki'
  
  def show
    unless @wiki.version > 0
      redirect_to page_url(@page, :action => 'edit')
      return
    end
    if @upart and not @upart.viewed? and @wiki.version > 1
      last = @wiki.find_version(@wiki.version - 1)
      @diffhtml = html_diff(
         # TODO: show all the changes we haven't seen, not just the last change.
         last.body_html,
         @wiki.body_html
      ) if last
    end
  end

  def edit
    if params[:cancel]
      @wiki.unlock
      return(redirect_to page_url(@page, :action => 'show'))
    elsif request.post?
      save_edits
    elsif request.get?
      @wiki.lock(Time.now, current_user)
    end
  end
  
  def version
    @version = @wiki.versions.find_by_version(params[:id])
  end
  
  def diff
    old_id, new_id = params[:id].split('-')
    @old = @wiki.find_version(old_id)
    @new = @wiki.find_version(new_id)
    @old_markup = @old.body || ''
    @new_markup = @new.body || ''
    @difftext = html_diff( @old_markup , @new_markup)
  end
  
  def preview
    # not yet
  end
  
  def break_lock
    @wiki.unlock
    redirect_to page_url(@page, :action => 'show')
  end
    
  protected
  
  def save_edits
    begin
      @wiki.body = params[:wiki][:body]
      if @wiki.version > params[:wiki][:version].to_i
        raise ErrorMessage.new("can't save your data, someone else has saved new changes first.")
      elsif not @wiki.editable_by? current_user
        raise ErrorMessage.new("can't save your data, someone else has locked the page.")
      end
      if save_revision(@wiki)
        current_user.updated(@page)
        @wiki.unlock
        redirect_to page_url(@page, :action => 'show')
      else
        message :object  => @wiki
      end
    rescue ActiveRecord::StaleObjectError
      # this exception is created by optimistic locking. 
      # it means that @wiki has change since we fetched it from the database
      message :error => "locking error. can't save your data, someone else has saved new changes first."
    rescue ErrorMessage => exc
      message :error => exc.to_s
    end
  end
  
  # save the wiki, and make a new version only if the last
  # version was not recently saved by current_user
  def save_revision(wiki)
    if wiki.recent_edit_by?(current_user)
      wiki.save_without_revision
      wiki.find_version(wiki.version).update_attributes(:body => wiki.body, :body_html => wiki.body_html, :updated_at => wiki.updated_at)
    else
      wiki.user = current_user
      wiki.save
    end  
  end
  
  def fetch_wiki
    return true unless @page
    @page.data ||= Wiki.new(:body => 'new page', :page => @page)
    @wiki = @page.data
  end
  
  def setup_view
    @show_attach = true
  end
  
end

