# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  include PageUrlHelper         # provides page_url()
  #include UrlHelper
  include Formy                 # helps create forms
  include LayoutHelper
  include LegacyHelper
  include TimeHelper
  include AjaxUiHelper
  include DataDisplayHelper
  include PageListHelper
  include ContextHelper
  include NetworkContentHelper
  #include PathFinder::Options   # for Page.find_by_path options
    
  #this should go away when we have working issue routes
  def issue_url(issue)
  	issue 
  end

  def link_to_group(group, options = {})
    options[:class] = ((options[:class] || '') << "name_link").strip
    link_to group.full_name, group_url(group), options
  end
  
  def link_to_user(user, options = {})
    options[:class] = ((options[:class] || '') << "name_link").strip
    link_to user.login, person_url(user), options
  end
end
