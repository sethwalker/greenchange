module GroupsContentHelper
  def blog
    @pages = @group.pages.find_with_access(:all, :user => current_user, :conditions => "type = 'Tool::Blog'", :order => "created_at DESC", :limit => 20)
  end

  def calendar
    @pages = @group.pages.find_with_access(:all, :user => current_user, :conditions => "pages.type = 'Tool::Event' AND pages.starts_at > '#{Time.now.to_s(:db)}'", :limit => 20, :order => "pages.starts_at ASC")
  end

  def discussions
    @pages = @group.pages.find_with_access(:all, :user => current_user, :include => {:discussion => :posts}, :conditions => "posts.id IS NOT NULL", :order => "posts.updated_at DESC", :limit => 20)
  end

  def media
    @pages = @group.pages.find_with_access(:all, :user => current_user, :conditions => "pages.type IN ('Tool::Asset', 'Tool::ExternalVideo')")
  end

  def action_alerts
    @pages = @group.pages.find_with_access(:all, :user => current_user, :conditions => "pages.type = 'Tool::ActionAlert'", :order => "pages.updated_at DESC", :limit => 10)
  end

  def pages_by_month
  end

  def promo_for(group)
    group.pages.find(:first, :order => "updated_at DESC") if group
  end

end

