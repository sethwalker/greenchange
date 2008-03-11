require File.dirname(__FILE__) + '/../spec_helper'

describe "PathFinder" do
  describe "find_and_paginate_by_path" do
    before do
      @stderr = $stderr
      Page.__send__ :extend, PathFinder::FindByPath
    end
    it "should be deprecated" do
      $stderr.should_receive('puts')
      Page.find_and_paginate_by_path('path')
    end
    after do
      $stderr = @stderr
    end
  end
end
