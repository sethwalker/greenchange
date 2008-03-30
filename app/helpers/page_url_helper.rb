require 'cgi'

module PageUrlHelper
   
  def page_url(page,*args)
    url_helper = case page
    when Tool::Video
      'video_url'
    when Tool::Asset
      'asset_url'
    when Tool::Blog, Tool::News, Tool::Event, Tool::Message
      "#{page.class.to_s.demodulize.underscore}_url"
    when Tool::TextDoc
      'wiki_url'
    when Tool::ActionAlert
      'action_url'
    when Tool::RankedVote
      'poll_url'
    when Tool::RateMany
      'survey_url'
    when Tool::TaskList
      'task_url'
    else
      return "/pages/show/#{page.to_param}"
    end
    self.__send__ url_helper.to_sym, page, *args
  end

  
  def filter_path
    @path ||= (params[:path] || [])
  end
  def parsed_path
    return @parsed_path if @parsed_path
    @parsed_path ||= controller.parse_filter_path(filter_path)
  end

  # used to create the page list headings
  # set member variable @path beforehand if you want 
  # the links to take it into account instead of params[:path]
  def list_heading(text, action, select_by_default=false)
    path = filter_path
    parsed = parsed_path
    selected = false
    arrow = ''
    if parsed.keyword?('ascending')
      link = page_path_link(text,"descending/#{action}")
      if parsed.first_arg_for('ascending') == action
        selected = true
        arrow = image_tag('ui/sort-asc.png')
      end
    elsif parsed.keyword?('descending')
      link = page_path_link(text,"ascending/#{action}")
      if parsed.first_arg_for('descending') == action
        selected = true
        arrow = image_tag('ui/sort-desc.png')
      end
    else
      link = page_path_link(text, "ascending/#{action}")
      selected = select_by_default
      arrow = image_tag('ui/sort-desc.png') if selected
    end
    "<th nowrap class='#{selected ? 'selected' : ''}'>#{link} #{arrow}</th>"
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
