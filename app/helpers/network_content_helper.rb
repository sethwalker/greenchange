module NetworkContentHelper

  def featured_pages( source )
    [ source.pages.find(:first, :order => "updated_at DESC") ].compact
  end
end
