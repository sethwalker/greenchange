
class Tool::TextDoc < Page
  define_index do
    indexes title
    indexes [summary, data.body], :as => 'content'
    has :public
    set_property :delta => true
  end

  icon       'wiki.png'
  class_display_name 'wiki'
  class_description 'A free-form text document.'
  belongs_to :data, :class_name => '::Wiki', :foreign_key => "data_id"
   
  def title=(value)
    write_attribute(:title,value)
    write_attribute(:name,value.nameize)
    #name ||= value.nameize
  end
  
end
