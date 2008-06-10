module AjaxUiHelper

  # Unobtrusive version of link_to_remote
  def link_to_remote( name, options, html_options={} )
    html_options[:class] = "remote #{html_options.delete(:class)}".strip
    link_to(name, options, html_options)
  end

  def jquery_javascript_library
    ''
    #return '' if @jquery_library_loaded
    #@jquery_library_loaded = true
    #javascript_include_tag( 'jquery/jquery-1.2.6.js' ) +
    #javascript_tag( 'var jQ$ = jQuery.noConflict();' )
  end
  def prototype_library
    return '' if @prototype_library_loaded
    @prototype_library_loaded = true
    javascript_include_tag 'prototype'
  end
  def jquery_effects
    return '' if @jquery_effects_loaded
    @jquery_effects_loaded = true
    jquery_javascript_library + 
    javascript_include_tag( 'jquery/ui/effects.core.js' ) +
    javascript_include_tag( 'jquery/ui/effects.slide.js' ) +
    javascript_include_tag( 'jquery/ui/effects.drop.js' )
  end

  # load the javascript tabs.  redefine the method when you're done so it can't be called again
  def load_javascript_tabs
    return if @javascript_tabs_loaded
    content_for :javascript,
      jquery_effects + 
      javascript_include_tag('tabs') 
    content_for :javascript_onload, "Crabgrass.Tabs.initialize_tab_blocks();"
    @javascript_tabs_loaded = true
  end

  def load_ajax_form_behaviors
    return if @ajax_form_behavior_loaded
    content_for :javascript, javascript_include_tag( 'forms' )
    content_for :javascript_onload,  
      'Crabgrass.Forms.initialize_radio_behavior(); Crabgrass.Forms.initialize_remote_actions();'
    @ajax_form_behavior_loaded = true
  end

  def load_ajax_list_behaviors
    return if @ajax_list_behavior_loaded
    content_for( :javascript, jquery_javascript_library +
      javascript_tag( <<-SCRIPT
      jQ$('ul.list .toolbar .delete.confirm').click( function( ev ) { 
        return confirm( 'You are about to delete this item.  You will not be able to undo this.' );
      });
      SCRIPT
      ))
    @ajax_list_behavior_loaded = true
  end


end
