require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::Asset do
  before do
    @p = Tool::Asset.new
  end
  it "should respond to image?" do
    @p.should respond_to(:image?)
  end
  it "should respond to audio?" do
    @p.should respond_to(:audio?)
  end
  it "should respond to video?" do
    @p.should respond_to(:video?)
  end
  it "should respond to document?" do
    @p.should respond_to(:document?)
  end
  it "should update type if content type changes" do
  end
end
