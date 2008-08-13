module IconHelper

  # supplies default css for icons by type
  # includes a dynamic background image for page types that should have one
  # returns a div with styling as dictated by html_options_for_icon_for
  def icon_for(item, html_options = {})
    content_tag 'div', '&nbsp;', html_options_for_icon_for(item, html_options )
  end

  # returns a hash of html options to add an icon to the element to which they are applied
  def html_options_for_icon_for( item, html_options = {} )
    item_type = ''

    %w[ Page Issue Group User Asset ].each do |type_check|
      if item.is_a?( Object.const_get(type_check) )
        item_type = type_check.downcase 
        custom_options = "extra_html_options_for_icon_for_#{item_type}"
        html_options.merge!( send( custom_options, item, html_options )) if respond_to? custom_options
      end
    end
    size_option = html_options.delete(:size) || 'standard'
    html_options.delete(:avatar_size) 
    html_options[:title] ||= item.try(:display_name)
    new_class = [ (html_options[:class] ||= ''), "icon", item_type, size_option.to_s, ['icon', size_option.to_s ].join('-') ]
    html_options[:class] = new_class.join(' ').strip
    html_options

  end

  def html_options_for_avatar_for( item, html_options ={} )
    size_option = html_options[:size] || 'standard'
    html_options[:class] = [ (html_options[:class] || ''), 'avatar', "avatar-#{size_option}" ].join(' ').strip
    #item_url_type = case item when User; 'person'; when Group; 'group'; when Page; 'page'; end
    #if item.respond_to?(:has_image?) && item.has_image? && item_url_type
    #  item_icon_method = "#{item_url_type}_icon_path"
    #  html_options[:style] = [ (html_options[:style]||nil), "background-image: url(#{ send( item_icon_method, item, :format => :png, :size => avatar_size_option )})"].compact.join(';')
    #end
    #if item.avatar
    #  html_options[:style] = [ (html_options[:style]||nil), "background-image: url(#{ avatar_url( :id => ( item.avatar || 0 ), :size => avatar_size_option )})"].compact.join(';')
    #end
    html_options[:style] = [ (html_options[:style]||nil), "background-image: url(#{ icon_path_for(item, html_options )})"].compact.join(';') if icon_path_for( item, html_options )
    html_options
  end

  def icon_path_for( item, html_options = {} )
    avatar_size_option = html_options[:avatar_size] || html_options[:size] || 'standard'
    item_url_type = case item when User; 'person'; when Group; 'group'; end# when Page; 'page'; end
    return nil unless item.respond_to?(:has_image?) && item.has_image? && item_url_type
    item_icon_method = "#{item_url_type}_icon_path"
    send( item_icon_method, item, :format => :png, :size => avatar_size_option )
  end

  # returns a css class to add an icon to the applied element
  def css_class_for_icon_for( item, html_options = {} )
    html_options_for_icon_for(item, html_options )[:class]
  end

  # returns the url for the image thumbnail if the page is an image
  def icon_url_for_image( item, html_options = {} )
    #return unless image = ( (( item.is_a?( Asset) && item.image?) ? item : nil ) || item.assets.detect { |a| a.image? } || (( item.data && item.data.is_a?(Asset) && item.data.image? ) ? item.data : nil ))
    image ||= item  if item.is_a?(Asset) && item.image?
    if item.is_a? Page
      image ||= item.primary_image
      #image ||= item.data if item.data && item.data.is_a?(Asset) && item.data.image? 
      #image ||= item.assets.detect { |a| a.image? } if item.assets
    end
    return unless image 
    filename_size_option = html_options[:size] || :standard
    thumb_file = image.public_filename( filename_size_option )
    thumb_file if File.exists? RAILS_ROOT + '/public' + thumb_file 
  end

  # returns the url for the video thumbnail if the page is a youtube video 
  def icon_url_for_youtube(page, html_options = {})
    return unless page.is_a?(Tool::ExternalVideo) and page.data and page.data.thumbnail_url
    page.data.thumbnail_url 
  end


  # returns a short, hyphenated version of the class name for use in stylesheets
  def css_page_type(page)
    css_class = page.class.name.demodulize.underscore.to_sym

    translations = { :wiki => [ :text_doc ], :video => [ :external_video ], :poll => [:ranked_vote], :blog => [ :repost ] }
    translated_page_type = translations.detect { | css, tool_types | css if tool_types.include? css_class }.first
    css_class = translated_page_type if translated_page_type

    allowed_types = [ :asset, :page, :news, :video, :action_alert, :wiki, :blog, :event, :gallery, :image, :audio, :poll, :discussion, :task_list, :petition ]
    if allowed_types.include? css_class
      css_class.to_s.gsub('_', '-')
    else
      'page'
    end
  end

  protected
    def extra_html_options_for_icon_for_page( page, html_options ={} )
      ie_page_class = [ 'page', css_page_type(page), (html_options[:size] || 'standard') ].join('-')
      html_options[:class] = [ (html_options[:class] || ''), css_page_type(page), ie_page_class ].join(' ').strip
      if custom_icon_url = ( ( icon_url_for_image( page, html_options ) or icon_url_for_youtube( page, html_options )))
        html_options[:style] = "background-image: url( #{custom_icon_url});"
        html_options[:class] << " youtube-thumbnail" if icon_url_for_youtube page 
        html_options[:class] << " image-thumbnail" if icon_url_for_image page 
      else
        html_options[:class] << " page-default"
      end
      html_options
    end
    def extra_html_options_for_icon_for_asset( asset, html_options ={} )
      html_options[:class] = [ (html_options[:class] || ''), 'asset' ].join(' ').strip
      if custom_icon_url = icon_url_for_image( asset, html_options ) 
        html_options[:style] = "background-image: url( #{custom_icon_url});"
        html_options[:class] << " image-thumbnail" if icon_url_for_image asset 
      else
        html_options[:class] << " page-default"
      end
      html_options
    end

    def extra_html_options_for_icon_for_issue( issue, html_options ={} )
      ie_issue_class = [ 'issue', issue.name.downcase.gsub(' ', '-'), (html_options[:size] || 'standard') ].join('-')
      html_options[:class] = [ (html_options[:class]||''), issue.name.downcase.gsub(' ', '-'), ie_issue_class ].join(' ').strip
      html_options
    end

    def extra_html_options_for_icon_for_user( user, html_options ={} )
      html_options.merge html_options_for_avatar_for( user, html_options )
    end

    def extra_html_options_for_icon_for_group( group, html_options ={} )
      html_options.merge html_options_for_avatar_for( group, html_options )
    end

end
