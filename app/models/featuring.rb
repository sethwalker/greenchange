class Featuring < ActiveRecord::Base
  belongs_to :issue
  belongs_to :page
end
