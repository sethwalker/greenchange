class Tool::RankedVote < Page

  icon 'ballot.png'
  class_display_name 'ranked vote'
  class_description 'Rank possibilities in order of preference.'
  belongs_to :data, :class_name => 'Poll::Poll'
    
  def initialize(*args)
    super(*args)
    self.data = Poll::Poll.new
  end
  
end

