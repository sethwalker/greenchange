class Poll::Possible < ActiveRecord::Base

  belongs_to :poll
  has_many :votes
  
end