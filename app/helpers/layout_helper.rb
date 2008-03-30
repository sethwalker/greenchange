module LayoutHelper
  include IconHelper

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

  def column_1_of_2( dataset )
    dataset[0, dataset.size/2]
  end

  def column_2_of_2(dataset)
    dataset[dataset.size/2, dataset.size]
  end
    
  
end
