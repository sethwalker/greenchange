class ActionAlert < Wiki
  include DocumentMetaData
  #has_one :document_meta, :foreign_key => "wiki_id"
  #delegate :creator, :creator_url, :source, :source_url, :published_at, :to => :document_meta
  #delegate :creator=, :creator_url=, :source=, :source_url=, :published_at=, :to => :document_meta

  def editable_by?(user)
    return true unless self.user
    user == self.user
  end

end
