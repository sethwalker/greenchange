class Tool::Repost < Tool::Blog
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
