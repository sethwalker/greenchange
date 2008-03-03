class IssueIdentification < ActiveRecord::Base
  belongs_to :issue
  belongs_to :issue_identifying, :polymorphic => true
end
