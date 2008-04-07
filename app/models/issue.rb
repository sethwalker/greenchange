class Issue < ActiveRecord::Base
  has_many_polymorphs :issue_identifyings, :from => [ :groups, :users, :pages], :through => :issue_identifications#, :source => :issue_identifying
  has_many :issue_identifications

  def to_param; name.downcase.gsub ' ', '-'; end

  def self.standard_set
    Issue.find :all, :order => 'name'
  end
end
