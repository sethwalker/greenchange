
class Tool::Discussion < Page

  icon 'discussion.png'
  class_display_name 'group discussion'
  class_description 'A group discussion on a particular topic.'
  belongs_to :data, :class_name => '::Discussion'

end

