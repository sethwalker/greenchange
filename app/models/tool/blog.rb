class Tool::Blog < Page
  icon 'wiki.png'
  class_display_name 'blog'
  class_description 'A blog'
  belongs_to :data, :class_name => '::Blog'
end
