class PageObserver < ActiveRecord::Observer
  def after_create(page)
    return true unless page.created_by
    NetworkEvent.create! :modified => page, :action => 'create', :user => page.created_by, :recipients => watchers(page), :data_snapshot => {:page => page, :page_created_by => page.created_by}
  end
  def after_update(page)
    return true unless page.updated_by
    recipients = page.network_events.find(:first, :conditions => ["user_id = ? AND network_events.created_at > ?", page.updated_by_id, 1.hour.ago]) ? [] : watchers(page)
    NetworkEvent.create! :modified => page, :action => 'update', :user => page.updated_by, :recipients => recipients, :data_snapshot => {:page => page, :page_created_by => page.created_by, :page_updated_by => page.updated_by}
  end

  def watchers(page)
    ( [ page.created_by ] << page.created_by.try(:contacts) << page.group.try(:members ) ).flatten.compact.uniq
  end
end
