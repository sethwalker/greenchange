class Tool::ActionAlert < Page
  define_index do
    indexes title
    indexes data.body, :as => 'content'
    has :public
    set_property :delta => true
  end

  icon 'page_white_lightning.png'
  class_display_name 'action alert'
  class_description 'An action alert'
  belongs_to :data, :class_name => '::ActionAlert', :foreign_key => 'data_id'

  def self.icon_path
    "/extensions/crabgrass_document_types/images/pages/#{self.icon}"
  end

  def self.big_icon_path
    "/extensions/crabgrass_document_types/images/pages/big/#{self.icon}"
  end
end
