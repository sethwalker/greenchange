# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  #include UrlHelper
  #include Formy                 # helps create forms
  #include LegacyHelper
  #include PageListHelper
  #include PathFinder::Options   # for Page.find_by_path options
  include PageUrlHelper         # provides page_url()
  include LayoutHelper
  include TimeHelper
  include AjaxUiHelper
  include DataDisplayHelper
  include ContextHelper
  include NetworkContentHelper
  include PermissionsHelper
    
  def issue_selector(thing_that_has_issues)
    Issue.find(:all).inject('') do |selector, issue|
      selector << "<label>" << check_box_tag('issues[]', issue.id, thing_that_has_issues.issues.include?(issue)) << "#{issue.name}</label>" 
    end
  end

  def link_to_group(group, options = {})
    group = Group.find_by_name(group) if group.is_a? String
    options[:class] = ((options[:class] || '') << "name_link").strip
    link_to group.full_name, group_url(group), options
  end
  
  def link_to_user(user, options = {})
    options[:class] = ((options[:class] || '') << "name_link").strip
    link_to user.login, person_url(user), options
  end

  def partials_in( path, filename_pattern = nil )
    full_path = "#{RAILS_ROOT}/app/views/#{path}"
    Dir.entries( full_path ).inject([]) do |matches, f| 
      if ( File.file? full_path + '/' + f ) && ( match = f.match( /_([^.]*)/  ))
        matches << match[1] if filename_pattern.nil? || match[1].match(filename_pattern )
      end
      matches
    end.uniq.sort
  end

  # placeholder method for globalize 2.0
  def _(value)
    value
  end
end
