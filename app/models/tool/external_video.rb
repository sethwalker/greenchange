class Tool::ExternalVideo < Tool::Video
  define_index do
    indexes title
    indexes summary, :as => 'content'
    has :public
    set_property :delta => true
  end

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

  def primary_image
    images = assets.select(&:image?)
    images.first unless images.empty?
  end

end
