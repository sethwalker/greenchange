class News < Wiki
  include DocumentMetaData

  def editable_by?(user)
    return true unless self.user
    user == self.user
  end


end
