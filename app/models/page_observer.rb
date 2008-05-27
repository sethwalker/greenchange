class PageObserver < ActiveRecord::Observer
  def after_create(page)
    NetworkEvent.create! :modified => page, :action => 'create', :user => page.created_by
  end
  def after_update(page)
    NetworkEvent.create! :modified => page, :action => 'update', :user => page.updated_by 
  end
end
