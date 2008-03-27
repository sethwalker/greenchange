class Tool::WikiController < Tool::BaseController
  include HTMLDiff
  append_before_filter :fetch_wiki

  def new
    @page = Tool::TextDoc.new :group_id => params[:group_id]
    @wiki = @page.build_data :body => 'new page'
  end

  def create
    @page = Tool::TextDoc.new params[:page]
    @page.created_by = current_user
    if @page.save
      if save_edits
        @page.tag_with(params[:tag_list]) if params[:tag_list]
        redirect_to(wiki_url(@page))
      else
        render :action => 'new'
      end
    else
      message :object => @page
      render :action => 'new'
    end
  end
  
  def show
    unless @wiki.version > 0
      redirect_to edit_wiki_url(@page)
      return
    end
    if @upart and !@upart.viewed? and @wiki.version > 1
      last_seen = @wiki.first_since( @upart.viewed_at )
      @diffhtml = html_diff(last_seen.body_html,@wiki.body_html) if last_seen
    end
  end

  def edit
    @wiki.lock(Time.now, current_user)
  end

  def update
    if params[:cancel]
      @wiki.unlock
      return redirect_to(wiki_url(@page))
    end
    if save_edits
      return redirect_to(wiki_url(@page))
    else
      render :action => 'edit'
    end
  end
  
  def version
    @version = @wiki.versions.find_by_version(params[:version])
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

  def print
    render :layout => "printer-friendly"
  end
  
  def preview
    # not yet
  end
  
  def break_lock
    @wiki.unlock
    redirect_to wiki_url(@page)
  end
    
  protected
  
  def save_edits
    @wiki = @page.data || @page.build_data
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
        return true
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
    return false
  end
  
  # save the wiki, and make a new version only if the last
  # version was not recently saved by current_user
  def save_revision(wiki)
    if wiki.recent_edit_by?(current_user)
      wiki.save_without_revision
      wiki.versions.find_by_version(wiki.version).update_attributes(:body => wiki.body, :body_html => wiki.body_html, :updated_at => Time.now)
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
  end
  
end

