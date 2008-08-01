class Tool::News < Page
  define_index do
    indexes title
    indexes [summary, data.body], :as => 'content'
    has :public
    set_property :delta => true
  end

  icon 'news.png'
  class_display_name 'news'
  class_description 'A news article'
  belongs_to :data, :class_name => '::News', :foreign_key => 'data_id'
end
