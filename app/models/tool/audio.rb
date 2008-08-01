class Tool::Audio < Tool::Asset
  define_index do
    indexes title
    indexes [ summary, data.filename, data.content_type ], :as => 'content'
    has :public
    set_property :delta => true
  end
end
