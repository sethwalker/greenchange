
class Tool::TextDoc < Page

  icon       'wiki.png'
  class_display_name 'wiki'
  class_description 'A free-form text document.'
  belongs_to :data, :class_name => 'Wiki'
   
  def title=(value)
    write_attribute(:title,value)
    write_attribute(:name,value.nameize)
    #name ||= value.nameize
  end
  
end
