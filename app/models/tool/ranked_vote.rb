class Tool::RankedVote < Page

  model Poll::Poll
  icon 'ballot.png'
  class_display_name 'ranked vote'
  class_description 'Rank possibilities in order of preference.'
    
  def initialize(*args)
    super(*args)
    self.data = Poll::Poll.new
  end
  
end

