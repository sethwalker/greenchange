module PageListHelper
  #
  # used to spit out a column value for a single row.
  # for example:
  #  page_column(page, :title)
  # this function exists so we can re-arrange the columns easily.
  #
  def page_list_cell(page, column, participation=nil)
    if column == :icon
      return icon_for( page, :size => :small )
    elsif column == :checkbox
      check_box('page_checked', page.id, {}, 'checked', '')
    elsif column == :title
      return page_list_title(page, column, participation)    
    elsif column == :updated_by or column == :updated_by_login
      return( page.updated_by ? link_to_user( page.updated_by ) : page.updated_by_login )
    elsif column == :created_by or column == :created_by_login
      return( page.created_by ? link_to_user( page.created_by ) : page.created_by_login )
    elsif column == :updated_at
      return friendly_date(page.updated_at)
    elsif column == :created_at
      return friendly_date(page.created_at)
    elsif column == :happens_at
      return friendly_date(page.happens_at)
    elsif column == :group or column == :group_name
      return( page.group_name ? link_to_group(page.group_name) : '&nbsp;')
    elsif column == :contributors_count or column == :contributors
      return page.contributors_count
    elsif column == :owner
      return (page.group_name || page.created_by_login)
    elsif column == :owner_with_icon
      return page_list_owner_with_icon(page)
    else
      return page.send(column)
    end
  end

  def page_list_owner_with_icon(page)
    if page.group
      return link_to_group(page.group)
    elsif page.created_by
      return link_to_user(page.created_by)
    end
  end
  
  def page_list_title(page, column, participation = nil)
    title = link_to(page.title, page_url(page))
    if participation and participation.instance_of? UserParticipation
      title += " " + image_tag("emblems/pending.png", :size => "11x11", :title => 'pending') unless participation.resolved?
      title += " " + image_tag("emblems/star.png", :size => "11x11", :title => 'star') if participation.star?
    else
      title += " " + image_tag("emblems/pending.png", :size => "11x11", :title => 'pending') unless page.resolved?
    end
    return title
  end
  
  def page_list_heading(column=nil)
    if column == :group or column == :group_name
      list_heading 'group'.t, 'group_name'
    elsif column == :icon 
      "<th></th>"
    elsif column == :checkbox
      page_list_toggle_all_script
      content_tag 'th', link_to( 'Toggle', '#', :id => 'inbox-toggle-selection' )
    elsif column == :updated_by or column == :updated_by_login
      list_heading 'updated by'.t, 'updated_by_login'
    elsif column == :created_by or column == :created_by_login
      list_heading 'created by'.t, 'created_by_login'
    elsif column == :updated_at
      list_heading 'updated'.t, 'updated_at'
    elsif column == :created_at
      list_heading 'created'.t, 'created_at'
    elsif column == :happens_at
      list_heading 'happens'.t, 'happens_at'
    elsif column == :contributors_count or column == :contributors
      #"<th>" + image_tag('ui/person-dark.png') + "</th>"
      list_heading image_tag('ui/person-dark.png'), 'contributors_count'
    elsif column
      list_heading column.to_s.t, column.to_s
    end    
  end

  def page_list_toggle_all_script
    content_for :javascript do 
      javascript_tag("Event.observe( document, 'dom:loaded', function() { Event.observe( $('inbox-toggle-selection'), 'click', function() { $('inbox_form').getInputs('checkbox').invoke('click'); } ); } ); ");
    end 
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

end
