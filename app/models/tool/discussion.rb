
class Tool::Discussion < Page

  icon 'discussion.png'
  class_display_name 'group discussion'
  class_description 'A group discussion on a particular topic.'
  belongs_to :data, :class_name => '::Discussion'

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

