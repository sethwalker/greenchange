require File.dirname( __FILE__ ) +  '/../../spec_helper'
require File.dirname( __FILE__ ) +  '/../../../lib/core_extensions/array_chunk'

describe "a chunkable array" do
  before do
    @start = [ 1, 2, 3 ]
    @even_chunked = [ [1], [2], [3] ]
  end
  it "chunks evenly" do
    @start.chunk(3).should == @even_chunked
  end

  it 'divides evenly' do
    (@start/3).should == @even_chunked
  end
  
  it 'chunks unevenly' do
    @start.chunk(2).should == [[ 1, 2], [3]]
  end

end
