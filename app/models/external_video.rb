class ExternalVideo < ExternalMedia
  YOUTUBE_TEMPLATE = %Q[<object width="%2$d" height="%3$d"><param name="movie" value="http://www.youtube.com/v/%1$s"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/%1$s" type="application/x-shockwave-flash" wmode="transparent" width="%2$d" height="%3$d"></embed></object>]
  GOOGLE_VIDEO_TEMPLATE = %Q[<embed id="VideoPlayback" style="width:%2$dpx;height:%3$dpx" allowFullScreen="true" src="http://video.google.com/googleplayer.swf?docid=%1$s&hl=en&fs=true" type="application/x-shockwave-flash"> </embed>]

  before_validation { @service_name = nil }
  validate :supported

  def supported
    errors.add(:media_embed, "is not supported (currently only youtube and google video)") unless service_name
  end

  def service_name
    @service_name ||= case media_embed
    when /youtube/
      :youtube
    when /video.google.com/
      :google_video
    end
  end

  def thumbnail_url
    case service_name
    when :youtube
      "http://img.youtube.com/vi/#{media_key}/default.jpg" if media_key
    end
  end

  def media_key
    read_attribute(:media_key) || extract_media_key_from_embed
  end

  def extract_media_key_from_embed
    case service_name
    when :youtube
      media_embed[/youtube.com\/v\/([\w-]+)/, 1]
    when :google_video
      media_embed[/video.google.com\/googleplayer.swf\?docid=([\w-]+)/, 1]
    end
  end

  def height
    media_embed[/height(="|:)(\d+)/, 2] || default_height
  end

  def width
    media_embed[/width(="|:)(\d+)/, 2] || default_width
  end

  def default_width
    case service_name
    when :youtube
      "425"
    when :google_video
      "400"
    end
  end

  def default_height
    case service_name
    when :youtube
      "355"
    when :google_video
      "326"
    end
  end

  def build_embed
    case service_name
    when :youtube
      YOUTUBE_TEMPLATE % [media_key, width, height]
    when :google_video
      GOOGLE_VIDEO_TEMPLATE % [media_key, width, height]
    end
  end
end
