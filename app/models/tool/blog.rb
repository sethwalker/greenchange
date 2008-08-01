class Tool::Blog < Page
  define_index do
    indexes title
    indexes [summary, data.body], :as => 'content'
    has :public
    set_property :delta => true
  end

  icon 'wiki.png'
  class_display_name 'blog'
  class_description 'A blog'
  belongs_to :data, :class_name => '::Blog', :foreign_key => "data_id"
end
