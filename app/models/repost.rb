class Repost < Wiki
  include DocumentMetaData
  def editable_by?(user)
    false
  end
end
