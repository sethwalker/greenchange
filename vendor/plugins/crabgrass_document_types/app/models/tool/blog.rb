class Tool::Blog < Page
  controller 'blog'
  model ::Blog
  icon 'wiki.png'
  class_display_name 'blog'
  class_description 'A blog'
  class_group 'wiki'
end
