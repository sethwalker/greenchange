class Tool::ActionAlert < Page
  icon 'page_white_lightning.png'
  class_display_name 'action alert'
  class_description 'An action alert'
  belongs_to :data, :class_name => '::ActionAlert'

  def self.icon_path
    "/extensions/crabgrass_document_types/images/pages/#{self.icon}"
  end

  def self.big_icon_path
    "/extensions/crabgrass_document_types/images/pages/big/#{self.icon}"
  end
end
