class Tool::ExternalVideo < Tool::Video
  class_display_name 'external video'
  class_description 'a video from an external service'

  def icon_path
    data.thumbnail_url
  end
end
