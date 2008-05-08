FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'plainlist'

WillPaginate::ViewHelpers.pagination_options[:renderer] = 'CrabgrassLinkRenderer'
WillPaginate::ViewHelpers.pagination_options[:prev_label] = '&laquo; previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'next &raquo;'
#

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| 
  if html_tag =~ /type="hidden"/
    html_tag
  elsif html_tag =~ /<label/ 
    "<div class=\"labelWithErrors\">#{html_tag}</div>" 
  else
    "<div class=\"fieldWithErrors\">#{html_tag}</div>"
  end
}

