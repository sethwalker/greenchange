module Tool::BaseHelper

  def header_for_page_create(page_class)
    %Q[
    <div class='page-class'>
      <span class='page-link' style='background: url(#{page_class.big_icon_path}) no-repeat 0% 50%'><b>#{page_class.class_display_name.t}</b>: #{page_class.class_description.t}</span>
    </div>
    ]
  end

  def show_notify_function
    remote_function(:url => pages_url(@page, :action=>'show_notify_form'))
  end
  
  def show_notify_click
    %Q[ $('notify_area').toggle(); if ($('page_notify_form')==null) {#{show_notify_function};} ]
  end

  def add_tool_page( header_text = nil )
    render :partial => 'tool/shared/title', :locals => { :title => ( header_text || title_for_new(@page.class.name.underscore.titleize)), :page => @page }
    render :partial => 'tool/shared/form_new'
  end
  alias :new_tool_page :add_tool_page

  def title_for_new( title )
    "Add a new #{title}"
  end

  def title_for_edit( title )
    "Edit #{title}"
  end

  def edit_tool_page( header_text = nil )
    render :partial => 'tool/shared/title', :locals => { :title => ( header_text || title_for_edit(@page.class.name.underscore.titleize)), :page => @page }
    render :partial => 'tool/shared/form_edit'
  end


  
end
