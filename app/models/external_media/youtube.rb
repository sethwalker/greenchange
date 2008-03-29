class ExternalMedia::Youtube < ExternalMedia::Base
  TEMPLATE = %Q[<object width="%2$d" height="%3$d"><param name="movie" value="%1$s"></param><param name="wmode" value="transparent"></param><embed src="%1$s" type="application/x-shockwave-flash" wmode="transparent" width="%2$d" height="%3$d"></embed></object>]

  #MAX_HEIGHT = 355
  #MAX_WIDTH = 425
  DEFAULT_WIDTH = 425
  DEFAULT_HEIGHT = 355

  def extract_uri_from_embed(embed)
    return unless embed
    uri = URI.extract(embed).detect {|u| (u =~ /^(https?:?\/\/)?(www.)?youtube.com\/v\/.*/)}
  end

  def build_embed(uri, width = DEFAULT_WIDTH, height = DEFAULT_HEIGHT)
    #assert_valid_uri(uri)
    TEMPLATE % [uri, width, height]
  end

  def media_embed
    embed = read_attribute(:media_embed)
    height = (match = /height="(\d+)"/.match(embed)) ? match[1] : DEFAULT_HEIGHT
    width = (match = /width="(\d+)"/.match(embed)) ? match[1] : DEFAULT_WIDTH
    uri = extract_uri_from_embed(embed)
    build_embed(uri, height, width)
  end

  def media_key
    read_attribute(:media_key) || extract_media_key_from_embed
  end

  def extract_media_key_from_embed
    if match = /youtube.com\/v\/([\w-]+)/.match(media_embed)
      match[1]
    end
  end


  def self.thumbnail_url(key)
    "http://img.youtube.com/vi/#{key}/default.jpg"
  end

  def thumbnail_url
    self.class.thumbnail_url(media_key)
  end
end
