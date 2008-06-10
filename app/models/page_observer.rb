class PageObserver < ActiveRecord::Observer
  def after_create(page)
    NetworkEvent.create! :modified => page, :action => 'create', :user => page.created_by, :recipients => watchers(page), :data_snapshot => {:page => page, :page_created_by => page.created_by}
  end
  def after_update(page)
    NetworkEvent.create! :modified => page, :action => 'update', :user => page.updated_by, :recipients => watchers(page), :data_snapshot => {:page => page, :page_created_by => page.created_by, :page_updated_by => page.updated_by}
  end

  def watchers(page)
    ( [ page.created_by ] << page.created_by.try(:contacts) << page.group.try(:members ) ).flatten.compact.uniq
  end
end
