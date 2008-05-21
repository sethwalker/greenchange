class Array
  def chunk(number_of_chunks)
    return [] unless number_of_chunks and !self.empty?
    chunk_size = (self.size.to_f/number_of_chunks).ceil
    self.enum_for(:each_slice, chunk_size).to_a
  end
  alias / chunk
end
