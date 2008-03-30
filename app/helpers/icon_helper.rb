module IconHelper

  # supplies default css for page icons by type
  # includes a dynamic background image for page types that should have one
  def icon_for(item, html_options = {})
    content_tag 'div', '&nbsp;', html_options_for_icon_of(item, html_options )
    #return icon_for_page(item, html_options) if item.is_a? Page
    #return icon_for_issue(item, html_options) if item.is_a? Issue
  end

  def icon_for_page( page, html_options = {} )
  end

  def html_options_for_icon_of( item, html_options = {} )
    item_type = ''
    %w[ Page Issue Group User ].each do |type_check|
      if item.is_a?( Object.const_get(type_check) )
        item_type = type_check.downcase 
        #RAILS_DEFAULT_LOGGER.debug "### checking type #{type_check} for #{item.name} type #{item_type}" 
        custom_options = "html_options_for_icon_of_#{item_type}"
        html_options.merge!( send( custom_options, item, html_options )) if respond_to? custom_options
      end
    end
    size_option = html_options.delete(:size) || 'standard'
    new_class = [ (html_options[:class] ||= ''), "icon", item_type, size_option.to_s ]
    html_options[:class] = new_class.join(' ').strip
    html_options

  end

  def html_options_for_icon_of_page( page, html_options ={} )
    html_options[:class] = [ (html_options[:class] || ''), css_page_type(page) ].join(' ').strip
    if custom_icon_url = ( ( icon_url_for_image( page ) or icon_url_for_youtube( page )))
      html_options[:style] = "background-image: url( #{custom_icon_url});"
      html_options[:class] << " youtube-thumbnail" if icon_url_for_youtube page 
    end
    html_options
  end

  def css_class_for_icon_of( item, html_options = {} )
    html_options_for_icon_of(item, html_options )[:class]
  end

  def html_options_for_icon_of_issue( issue, html_options ={} )
    html_options[:class] = [ (html_options[:class]||''), issue.name.downcase.gsub(' ', '-') ].join(' ').strip
    html_options
  end

  def html_options_for_icon_of_user( user, html_options ={} )
    html_options.merge html_options_for_avatar( group, html_options )
  end

  def html_options_for_icon_of_group( group, html_options ={} )
    html_options.merge html_options_for_avatar( group, html_options )
  end

  def html_options_for_avatar( item, html_options ={} )
    avatar_size_option = html_options[:avatar_size] || html_options[:size] || 'standard'
    html_options[:style] = [ (html_options[:style]||nil), "background-image: url(#{ avatar_url( :id => ( item.avatar || 0 ), :size => avatar_size_option )})"].compact.join(';')
    html_options
  end

  # returns the url for the image thumbnail if the page is an image
  def icon_url_for_image( page )
    return unless image = ( page.assets.detect { |a| a.image? } || page.data if page.is_a?(Tool::Image) )
    image.public_filename(:preview)  
  end

  # returns the url for the video thumbnail if the page is a youtube video 
  def icon_url_for_youtube(page)
    return unless page.is_a?(Tool::ExternalVideo) and page.data and page.data.thumbnail_url
    page.data.thumbnail_url 
  end


  # returns a short, hyphenated version of the class name for use in stylesheets
  def css_page_type(page)
    css_class = page.class.name.demodulize.underscore.to_sym

    translations = { :wiki => [ :text_doc ], :video => [ :external_video ] }
    translated_page_type = translations.detect { | css, tool_types | css if tool_types.include? css_class }.first
    css_class = translated_page_type if translated_page_type

    allowed_types = [ :asset, :page, :news, :video, :action_alert, :wiki, :blog ]
    if allowed_types.include? css_class
      css_class.to_s.gsub('_', '-')
    else
      'page'
    end
  end

end
