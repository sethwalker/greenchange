require 'asset'
class Tool::Asset < Page

  class_display_name 'file'
  class_description 'an uploaded file'
  belongs_to :data, :class_name => '::Asset'

  def icon
    return asset.small_icon if asset
    return 'package.png' 
  end
  
  # for the page class icon
  def self.icon
    'package.png'
  end
  
  delegate :image?, :movie?, :video?, :audio?, :other?, :pdf?, :document?, :to => :data

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

  def primary_image
    return data if data and data.image?
    super
  end
end
