class CrabgrassLinkRenderer < WillPaginate::LinkRenderer
  def to_html
    links = @options[:page_links] ? windowed_links : []
    # previous/next buttons
    links.unshift page_link(@collection.previous_page, @collection.previous_page ? 'nextpage' : 'disablepage', @options[:prev_label])
    links.push    page_link(@collection.next_page,     @collection.next_page ? 'nextpage' : 'disablepage', @options[:next_label])

    html = links.join(@options[:separator])
    html = @template.content_tag(:ul, html)
    @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
  end

    def page_link(page, li_class = 'currentpage', text = nil)
      text ||= page.to_s
      if page and page != current_page
        options = (li_class == 'currentpage') ? {} : {:class => li_class}
        url = if (@page = @template.instance_variable_get(:@page))
          @template.page_url(@page, param_name => page)
        else
          url_options(page)
        end
        @template.content_tag :li, @template.link_to(text, url, :rel => rel_value(page)), options
      else
        @template.content_tag :li, text, :class => li_class
      end
    end

    def windowed_links
      prev = nil

      visible_page_numbers.inject [] do |links, n|
        # detect gaps:
        links << gap_marker if prev and n > prev + 1
        links << page_link(n)
        prev = n
        links
      end
    end

end
