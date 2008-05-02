module DocumentMetaData
  def self.included(base)
    base.class_eval do
      has_one :document_meta, :foreign_key => "wiki_id"
      delegate :creator, :creator_url, :source, :source_url, :published_at, :to => :document_meta
      delegate :creator=, :creator_url=, :source=, :source_url=, :published_at=, :to => :document_meta
      after_save :document_meta_save
    end
  end

  def document_meta_data
    self.document_meta ||= self.build_document_meta
  end

  def document_meta_data=(meta_data)
    return if meta_data.values.all?(&:blank?)
    if document_meta
      document_meta.attributes = meta_data
    else
      build_document_meta( meta_data )
    end
  end

  def document_meta_save
    document_meta.save if document_meta
  end
end
