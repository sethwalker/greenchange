require 'poll/poll'

class Tool::RateMany < Page

  icon 'rate-many.png'
  class_display_name 'approval vote'
  class_description "Approve or disapprove of each possibility."
  belongs_to :data, :class_name => 'Poll::Poll'
    
  def initialize(*args)
    super(*args)
    self.data = Poll::Poll.new
  end
  
end
