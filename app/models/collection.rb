class Collection < ActiveRecord::Base
  has_many :collectings
  has_many_polymorphs :collectables, :from => [ :assets, :pages ], :through => :collectings
  belongs_to :page

  delegate :name, :to => :page
end
