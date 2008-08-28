class Issue < ActiveRecord::Base
  has_many_polymorphs :issue_identifyings, :from => [ :groups, :users, :pages], :through => :issue_identifications#, :source => :issue_identifying
  has_many :issue_identifications
  has_many :featurings
  has_many :featured_pages, :through => :featurings, :class_name => 'Page', :source => 'page'

  def to_param; name.downcase.gsub ' ', '-'; end
  def display_name; name; end

  def self.standard_set
    Issue.find :all, :order => 'name'
  end

  def features?(item)
    featured_pages.include? item
  end

  def feature_for(item)
    featurings.find_by_page_id item.id
  end
end
