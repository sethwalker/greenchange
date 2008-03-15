require 'asset'
class Tool::Asset < Page
  controller 'asset'
  model ::Asset

  class_display_name 'file'
  class_description 'an uploaded file'
  class_group 'asset'

  belongs_to :asset_data, :foreign_key => "data_id", :class_name => '::Asset'

  def icon
    return asset.small_icon if asset
    return 'package.png' 
  end
  
  # for the page class icon
  def self.icon
    'package.png'
  end
  
  before_save :update_type
  def update_type
    if data && data.image?
      self.type = "Tool::Image"
    end
  end

  after_save :update_access
  def update_access
    asset.update_access if asset
  end

  def asset
    self.data
  end

  def asset=(a)
    self.data = a
  end

  # title is the filename if title hasn't been set
  def title
    self['title'] || (self.data.filename.nameize if self.data && self.data.filename)
  end
end
