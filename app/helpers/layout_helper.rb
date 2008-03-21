module LayoutHelper
  ##########################################
  # PAGE ICONS
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

  def icon_url_for_image( page )
    return unless image = ( page.assets.detect { |a| a.image? } || page.data if page.is_a?(Tool::Image) )
    image.public_filename(:thumb)  
  end

  def icon_url_for_youtube(page)
    return unless page.is_a?(Tool::ExternalVideo) and page.data and page.data.thumbnail_url
    page.data.thumbnail_url 
  end


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

  ##########################################
  # BREADCRUMBS and CONTEXT
  
  def bread
    @breadcrumbs
  end
  
  def link_to_breadcrumbs
    if @breadcrumbs and @breadcrumbs.length > 1
      @breadcrumbs.collect{|b| link_to b[0],b[1]}.join ' &raquo; ' 
    end
  end
  
  def first_breadcrumb
    @breadcrumbs.first.first if @breadcrumbs.any?
  end
 
  #########################################
  # TITLE
  
  def title_from_context
    (
      [@html_title] +
      (@context||[]).collect{|b|truncate(b[0])}.reverse +
      [Crabgrass::Config.site_name]
    ).compact.join(' - ')
  end
    
  #########################################
  # SIDEBAR 
  
  def leftbar 
    @leftbar ? "<div id='leftbar'>\n#{render :partial => @leftbar}</div>\n" : ''
  end
  
  def rightbar
    @rightbar ? "<div id='rightbar'>\n#{render :partial => @rightbar}</div>\n" : ''
  end

  def sidebar
    leftbar + rightbar
  end
  
  def sidebar_space
    style = ''
    style += "margin-left: 0;" unless @leftbar
    style += "margin-right: 0;" unless @rightbar
    style
  end
    
  ###########################################
  # STYLESHEET
  
  # custom stylesheet
  # rather than include every stylesheet in every request, some stylesheets are 
  # only included if they are needed. a controller can set a custom stylesheet
  # using 'stylesheet' in the class definition, or an action can set @stylesheet.
  # you can't do both at the same time.
  def stylesheet
    if @stylesheet
      @stylesheet # set for this action
    else
      controller.class.stylesheet # set for this controller
    end
  end
  
  def http_plain
    'http://' + controller.request.host_with_port
  end
  
  ############################################
  # JAVASCRIPT
  
  def get_unobtrusive_javascript
    controller.get_unobtrusive_javascript
  end
  
  ############################################
  # BANNER

  # banner stuff
  def banner_style
    "background: #{@banner_style.background_color}; color: #{@banner_style.color};"
  end  
  def banner_background
    @banner_style.background_color
  end
  def banner_foreground
    @banner_style.color
  end
  def banner
    @banner_partial
  end
  
  ############################################
  # CUSTOM THEME
  
  def background_color
    "#ccc"
  end
  def background
    #'url(/images/test/grey-to-light-grey.jpg) repeat-x;'
    'url(/images/background/grey.png) repeat-x;'
  end

  # return all the custom css which might apply just to this one group
  def theme_styles
    style = []
     if banner
       style << 'body {background-color: %s}' % background_color
       style << '#main {background: %s}' % background if background
#       style << 'div.sidehead {background: %s;}' % banner_background
       style << 'div.sidehead {background: %s;}' % '#bbb'
       style << '#banner {%s}' % banner_style
       style << '#banner a.name_link {color: %s; text-decoration: none;}' %
                banner_foreground
       style << '#topmenu li.selected span a {background: %s; color: %s}' %
                [banner_background, banner_foreground]
      
       #xmain {background: #fff url(/images/shadows/small-top.png) repeat-x top;}
     end
    style.join("\n")
  end

end
