class Tool::News < Page
  icon 'news.png'
  class_display_name 'news'
  class_description 'A news article'
  belongs_to :data, :class_name => '::News'
end
