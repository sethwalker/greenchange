module Greencloth
module Inline

  private
 
    ###############################################################3
  # INLINE FILTERS
  #
  # Here lie the greencloth inline filters. An inline filter
  # processes text within a block.
  #
  
  def xglyphs_textile( text, level = 0 )
    if text !~ HASTAG_MATCH
      pgl text
    else
      text.gsub!( ALLTAG_MATCH ) do |line|
        if $1.nil?
          glyphs_textile( line, level + 1 )
        end
        line
      end
    end
  end
  
  CRABGRASS_LINK_RE = /
    (^|.)         # start of line or any character
    \[            # begin [
    [ \t]*        # optional white space
    ([^\[\]]+)    # $text : one or more characters that are not [ or ]
    [ \t]*        # optional white space
    \]            # end ]
  /x 

  def inline_crabgrass_link( text ) 
    text.gsub!( CRABGRASS_LINK_RE ) do |m|
      preceding_char, text = $~[1..2]
      if preceding_char == '\\'
        $~[0].sub('\\[', '[').sub('\\]', ']')
      else
        # $text = "from -> to"
        from, to = text.split(/[ ]*->[ ]*/)[0..1]
        to ||= from # in case there is no "->"
        if to =~ /^(\/|https?:\/\/)/
          # assume $to is an absolute path or full url
          atts = " href=\"#{to}\""
          text = from
        else
          # $to = "group_name / page_name"
          group_name, page_name = to.split(/[ ]*\/[ ]*/)[0..1]
          unless page_name
            # there was no group indicated, so $group_name is really the $page_name
            page_name = group_name
            group_name = @default_group
          end
          text = from =~ /\// ? page_name : from
          atts = " href=\"/#{nameize group_name}/#{nameize page_name}\""
        end
        atag = bypass_filter("<a#{ atts }>#{ text }</a>")
        "#{preceding_char}#{atag}"
      end
    end
  end
  
  # eventually, it would be nice to support link titles
  # and references:
  #   atts << " title=\"#{ title }\"" if title
  #   atts = shelve( atts )  
  
  
  #
  # characters that might be found in a valid URL
  # according to the RFC, although some are rarely
  # seen in the wild.
  #
  # alphnum: a-z A-Z 0-9 
  #    safe: $ - _ . +
  #   extra: ! * ' ( ) ,
  #  escape: %
  #
  # additionally, the "~" character is common although expressly
  # excluded from the list of valid characters in the RFC. go figure.
  #
  
  URL_CHAR = '\w' + Regexp::quote('+%$*\'()-~')
  URL_PUNCT = Regexp::quote(',.;:!')
  
  AUTO_LINK_RE = %r{
      ( https?:// | www\. )
      [^\s<]+
    }x unless const_defined?(:AUTO_LINK_RE)

  BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }

  # 
  # auto links are extracted and put in @pre_list so they
  # can escape the inline filters.
  #                       
  def inline_auto_link_urls(text)
    text.gsub!(AUTO_LINK_RE) do
      href = $&
      punctuation = ''
      # detect already linked URLs
      if $` =~ /<a\s[^>]*href="$/
        # do not change string; URL is alreay linked
        href
      else
        # don't include trailing punctuation character as part of the URL
        if href.sub!(/[^\w\/-]$/, '') and punctuation = $& and opening = BRACKETS[punctuation]
          if href.scan(opening).size > href.scan(punctuation).size
            href << punctuation
            punctuation = ''
          end
        end
 
        link_text = truncate href, 42
        href = 'http://' + href unless href.index('http') == 0
 
        bypass_filter( %(<a href="#{href}">#{link_text}</a>) ) + punctuation
      end
    end
  end

end
end

