module UrlHelper
  def url_for_group(group, options ={})
    options[:action] = 'show' unless options[:action]
    url_for :controller => 'groups', :action => options[:action], :id => group
  end

  def link_to_group(group)
    link_to group.full_name, url_for_group(group), :class => 'name_link'
  end

  def url_for_user(user, options = {})
    options[:action] = 'show' unless options[:action]
    url_for :controller => 'people', :action => options[:action], :id => user
  end
  alias :url_for_person :url_for_user
  
  def link_to_user(user)
    link_to user.login, url_for_user(user), :class => 'name_link'
  end
end
