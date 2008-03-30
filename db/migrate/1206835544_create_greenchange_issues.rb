class CreateGreenchangeIssues < ActiveRecord::Migration
  ISSUES = [ 'Climate crisis', 'Corporate power', 'Economic justice', 'Environment', 'Human Rights', 'Politics', 'Social justice', 'War and peace', ]
  def self.up
    ISSUES.each { |issue_name| Issue.find_or_create_by_name( issue_name ) }
  end

  def self.down
    ISSUES.each { |issue_name| Issue.find_by_name(issue_name).try(:destroy) }
  end
end
