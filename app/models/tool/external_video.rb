class Tool::ExternalVideo < Tool::Video
  class_display_name 'external video'
  class_description 'a video from an external service'
  belongs_to :data, :class_name => 'ExternalMedia::Youtube'

  def update_access; end

  def icon_path
    data.thumbnail_url
  end

  def title
    read_attribute('title') 
  end
end
