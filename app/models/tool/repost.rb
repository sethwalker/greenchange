class Tool::Repost < Tool::Blog
  indexes.clear
  define_index do
    indexes title
    indexes [summary, data.body], :as => 'content'
    has :public
    set_property :delta => true
  end
  belongs_to :data, :class_name => '::Repost', :foreign_key => "data_id"
  def allows?(user, action)
    action = action.to_sym

    unless [:view, :edit, :participate, :admin].include? action
        action = Permission.alias_for( action )
    end
    return false if action == :edit
    super(user, action)
  end
end
