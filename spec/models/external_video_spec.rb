require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalVideo do
  def sample_youtube_embed
    %Q[<object width="426" height="356"><param name="movie" value="http://www.youtube.com/v/6VdNcCcweL0&rel=1"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/6VdNcCcweL0&rel=1" type="application/x-shockwave-flash" wmode="transparent" width="426" height="356"></embed></object>]
  end
  SAMPLE_YOUTUBE_URL = "http://www.youtube.com/watch?v=6VdNcCcweL0"

  def sample_google_video_embed
    %Q[<embed id="VideoPlayback" style="width:401px;height:327px" allowFullScreen="true" src="http://video.google.com/googleplayer.swf?docid=-4984012277241504290&hl=en&fs=true" type="application/x-shockwave-flash"> </embed>]
  end
  SAMPLE_GOOGLE_VIDEO_URL = "http://video.google.com/videoplay?docid=-4984012277241504290"

  describe "youtube" do
    before do
      @video = new_external_video(:media_embed => sample_youtube_embed)
    end
    it "knows it's youtube" do
      @video.service_name.should == :youtube
    end
    it "has a youtube thumbnail url" do
      @video.thumbnail_url.should == "http://img.youtube.com/vi/6VdNcCcweL0/default.jpg"
    end
    it "has a media key" do
      @video.media_key.should == '6VdNcCcweL0'
    end
    it "has a height" do
      @video.height.should == "356"
    end
    it "has a default height" do
      @video.media_embed.gsub!("height","")
      @video.height.should == "355"
    end
    it "has a width" do
      @video.width.should == "426"
    end
    it "has a default width" do
      @video.media_embed.gsub!("width","")
      @video.width.should == "425"
    end
    it "is valid" do
      @video.should be_valid
    end
  end

  describe "google video" do
    before do
      @video = new_external_video(:media_embed => sample_google_video_embed)
    end
    it "knows it's google video" do
      @video.service_name.should == :google_video
    end
    it "has a generic video thumbnail url" do
      @video.thumbnail_url.should be_nil
    end
    it "has a media key" do
      @video.media_key.should == '-4984012277241504290'
    end
    it "has a height" do
      @video.height.should == "327"
    end
    it "has a default height" do
      @video.media_embed.gsub!("height","")
      @video.height.should == "326"
    end
    it "has a width" do
      @video.width.should == "401"
    end
    it "has a default width" do
      @video.media_embed.gsub!("width","")
      @video.width.should == "400"
    end
    it "is valid" do
      @video.should be_valid
    end
  end
  
  describe "invalid embed" do
    before do
      @video = new_external_video(:media_embed => "some malicious code or something")
    end
    it "is not valid" do
      @video.should_not be_valid
    end
  end
end
