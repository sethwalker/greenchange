require 'cgi'

module PageUrlHelper
   
  def page_url(page,*args)
    tool_page_url(page, *args)
  end

  def tool_page_url(page, *args)
    url_helper = tool_page_route_type( page )
    if url_helper == 'page'
      return "/pages/#{page.to_param}"
    end
    self.__send__ "#{url_helper}_url".to_sym, page, *args
  end

  def tool_page_path(page, *args)
    url_helper = tool_page_route_type( page )
    self.__send__ "#{url_helper}_path".to_sym, page, *args
  end

  def edit_tool_page_path( page, *args )
    url_helper = tool_page_route_type( page )
    self.__send__ "edit_#{url_helper}_path".to_sym, page, *args
  end

  def tool_pages_url(page, page_context = nil )

    url_helper = tool_page_route_type( page )
    plural_helper = ( url_helper.pluralize == url_helper) ? "#{url_helper}_index" : url_helper.pluralize
    self.send( [ context_path_prefix_type(page_context), plural_helper, 'url'].compact.join('_'))
  end

  def tool_pages_path(page, page_context = nil )

    url_helper = tool_page_route_type( page )
    plural_helper = ( url_helper.pluralize == url_helper) ? "#{url_helper}_index" : url_helper.pluralize
    #self.send( [ context_path_prefix_type(page_context), plural_helper, 'path'].compact.join('_'))
    scoped_path(plural_helper, :scope => page_context)
  end

  def tool_pages_title(page)
    tool_page_route_type(page).pluralize.titleize
  end

  def tool_page_route_type(page)
    case page
      when Tool::Video
        'video'
      when Tool::Image
        'photo'
      when Tool::Asset
        'upload'
      when Tool::Blog, Tool::News, Tool::Event, Tool::Discussion
        "#{page.class.to_s.demodulize.underscore}"
      when Tool::TextDoc
        'wiki'
      when Tool::ActionAlert
        'action'
      when Tool::RankedVote
        'poll'
      when Tool::RateMany
        'survey'
      when Tool::TaskList
        'task'
      else
        'page'
    end
  end

  
  def filter_path
    @path ||= (params[:path] || [])
  end
  def parsed_path
    return @parsed_path if @parsed_path
    @parsed_path ||= parse_filter_path(filter_path)
  end

  # used to create the page list headings
  def page_path_link(text,path='',image=nil)
    hash = params.dup
    current_path = parsed_path().dup.remove_sort.to_s
    current_path += '/' if current_path.any? and !current_path.ends_with? '/'
    hash[:path] = current_path + path
    #for tags this isn't right:
    # todo: do not hard code the action here.
    if params[:controller] == 'groups' && params[:action] == 'show'
      hash[:action] = 'search'
    elsif params[:controller] == 'inbox'
      hash[:action] = 'index'
    elsif params[:controller] == 'person'
      hash[:action] = 'search'
      hash[:id] ||= hash['_context']
    end
    hash.delete('_context')
    link_to text, hash
  end

  
end
