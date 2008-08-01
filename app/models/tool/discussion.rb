
class Tool::Discussion < Page
  define_index do
    indexes title
#    indexes discussion.posts.body, :as => 'content'
    indexes data.posts.body, :as => 'content'
    has :public
    set_property :delta => true
  end

  icon 'discussion.png'
  class_display_name 'group discussion'
  class_description 'A group discussion on a particular topic.'
  belongs_to :data, :class_name => '::Discussion', :foreign_key => 'data_id'

  alias :discussion :data
#  alias :build_data :build_discussion
#  def update_data
#    if @page_data
#      commence_discussion
#      discussion.update_attributes @page_data
#      @page_data = nil
#    end
#  end
#
end
