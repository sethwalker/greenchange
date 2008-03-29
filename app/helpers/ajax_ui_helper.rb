module AjaxUiHelper

  # Unobtrusive version of link_to_remote
  def link_to_remote( name, options, html_options={} )
    html_options[:class] = "remote #{html_options.delete(:class)}".strip
    link_to(name, options, html_options)
  end

  def jquery_javascript_includes
    javascript_include_tag( 'jquery/jquery' ) +
    javascript_include_tag( 'jquery/jquery.dimensions.js' )+
    javascript_include_tag( 'jquery/enchant/fx' )+
    javascript_tag( 'jQuery.noConflict();' )+
    javascript_include_tag( 'jquery/enchant/fx.slide.js' )
  end

  # load the javascript tabs.  redefine the method when you're done so it can't be called again
  def load_javascript_tabs
    return if @javascript_tabs_loaded
    content_for :javascript,
      jquery_javascript_includes + 
      javascript_include_tag('tabs') + 
      javascript_tag( 'Event.observe( document, "dom:loaded", function() { Crabgrass.Tabs.initialize_tab_blocks(); });' )
    @javascript_tabs_loaded = true
  end

  def load_ajax_form_behaviors
    return if @ajax_form_behavior_loaded
    content_for :javascript, javascript_include_tag( 'forms' )
    content_for :javascript_onload,  
      'Crabgrass.Forms.initialize_radio_behavior(); Crabgrass.Forms.initialize_remote_actions();'
    @ajax_form_behavior_loaded = true
  end


end
