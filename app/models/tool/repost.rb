class Tool::Repost < Tool::Blog
  belongs_to :data, :class_name => '::Repost', :foreign_key => "data_id"
end
