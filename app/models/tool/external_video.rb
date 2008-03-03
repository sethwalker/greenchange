class Tool::ExternalVideo < Page
  controller 'external_video'
  class_display_name 'external video'
  class_description 'a video from an external service'
  class_group 'video'

  def icon_path
    data.thumbnail_url
  end
end
