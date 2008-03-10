class Collection < ActiveRecord::Base
  has_many :collectings
  has_many_polymorphs :collectables, :from => [ :assets, :pages ], :through => :collectings
  belongs_to :page
  #belongs_to :user
  #belongs_to :group

  delegate :<<, :to => :collectables
  delegate :include?, :to => :collectables
  delegate :includes?, :to => :collectables

  delegate :<<, :to => :collectables
  delegate :include?, :to => :collectables
  delegate :includes?, :to => :collectables

  def name
    return page.name if page
    permission.to_s.humanize if permission
  end
end
