class Collection < ActiveRecord::Base
  has_many :collectings
  has_many_polymorphs :collectables, :from => [ :assets, :pages ], :through => :collectings
  belongs_to :page

  belongs_to :user
  belongs_to :group

  def name
    return page.name if page
    permission.to_s.humanize if permission
  end

end
