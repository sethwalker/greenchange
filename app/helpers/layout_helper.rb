module LayoutHelper

  # supplies default css for page icons by type
  # includes a dynamic background image for page types that should have one
  def icon_for(page, html_options = {})
    html_options[:class] ||= ''
    html_options[:class] << " big icon page #{css_page_type(page)}"
    html_options[:class].strip!

    if custom_icon_url = ( ( icon_url_for_image( page ) or icon_url_for_youtube( page )))
      html_options[:style] = "background-image: url( #{custom_icon_url});"
      html_options[:class] << " youtube-thumbnail" if icon_url_for_youtube page 
    end
    content_tag 'div', '&nbsp;', html_options
  end

  # returns the url for the image thumbnail if the page is an image
  def icon_url_for_image( page )
    return unless image = ( page.assets.detect { |a| a.image? } || page.data if page.is_a?(Tool::Image) )
    image.public_filename(:thumb)  
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

  # boolean. does this page have a widened sidebar block?
  def extended_sidebar?
    ( controller.controller_name =~ /groups|people|issues/ and controller.action_name == 'show' )
  end
  
  # returns avatar divs for people or groups
  def avatar_for(viewable, size='medium', options={})
    #image_tag avatar_url(:viewable_type => viewable.class.to_s.downcase, :viewable_id => viewable.id, :size => size), :alt => 'avatar', :size => Avatar.pixels(size), :class => 'avatar'
    image_tag avatar_url(:id => (viewable.avatar||0), :size => size), :alt => 'avatar', :size => Avatar.pixels(size), :class => (options[:class] || "avatar avatar_#{size}")
  end
  

  #assigns the title for display at the top of the page
  def html_title
    title =  []
    title <<  @page.title if @page
    title <<  @group.name if @group
    title <<  @person.name if @person
    title <<  @issue.name if @issue
    title <<  controller.controller_name
    title <<  controller.action_name
    #title <<  (@context||[]).collect{|b|truncate(b[0])}.reverse 
    title <<  Crabgrass::Config.site_name
    title.compact.join(' - ')
  end

  # merges the :class => "selected" into passed options if the first argument is true
  def selected_if( selected, options = {} )
    return options unless selected
    if options[:class]
      options[:class]  << " selected"
    else 
      options[:class] = 'selected'
    end
    options
  end
    
  
end
