require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalMedia do
  SAMPLE_YOUTUBE_EMBED = %Q[
  <object width="425" height="355"><param name="movie" value="http://www.youtube.com/v/6VdNcCcweL0&rel=1"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/6VdNcCcweL0&rel=1" type="application/x-shockwave-flash" wmode="transparent" width="425" height="355"></embed></object>
  ]
  SAMPLE_YOUTUBE_URL = "http://www.youtube.com/watch?v=6VdNcCcweL0"

  SAMPLE_BLIP_TV_EMBED_LEGACY_PLAYER = %Q[
  <center>                              <script type="text/javascript" src="http://blip.tv/scripts/pokkariPlayer.js?ver=2007111701"></script><script type="text/javascript" src="http://blip.tv/syndication/write_player?skin=js&posts_id=527547&source=3&autoplay=true&file_type=flv&player_width=&player_height="></script><div id="blip_movie_content_527547"><a rel="enclosure" href="http://blip.tv/file/get/Aspiration-VoicesFromOpenTranslationTools2007930.flv" onclick="play_blip_movie_527547(); return false;"><img title="Click to play" alt="Video thumbnail. Click to play"  src="http://blip.tv/file/get/Aspiration-VoicesFromOpenTranslationTools2007930.flv.jpg" border="0" title="Click To Play" /></a><br /><a rel="enclosure" href="http://blip.tv/file/get/Aspiration-VoicesFromOpenTranslationTools2007930.flv" onclick="play_blip_movie_527547(); return false;">Click To Play</a></div>                   </center>
  ]

  SAMPLE_BLIP_TV_EMBED_MOST_BLOGS_AND_WEB_SITES = %Q[
  <object type="application/x-shockwave-flash" data="http://blip.tv/scripts/flash/showplayer.swf?enablejs=true&file=http%3A//blip.tv/rss/flash/527547&feedurl=http%3A//aspiration.blip.tv/rss/&autostart=false&brandname=Aspiration&brandlink=http%3A//aspiration.blip.tv/" width="400" height="255" allowfullscreen="true" id="showplayer"><param name="movie" value="http://blip.tv/scripts/flash/showplayer.swf?enablejs=true&file=http%3A//blip.tv/rss/flash/527547&feedurl=http%3A//aspiration.blip.tv/rss/&autostart=false&brandname=Aspiration&brandlink=http%3A//aspiration.blip.tv/" /><param name="quality" value="best" /></object>
  ]

  SAMPLE_BLIP_TV_URL = "http://blip.tv/file/522086/"


  it "should extract uri from embed" do
    yt = ExternalMedia::Youtube.new
    uri = yt.extract_uri_from_embed(SAMPLE_YOUTUBE_EMBED)
    uri.should == 'http://www.youtube.com/v/6VdNcCcweL0&rel=1'
  end

  it "should create a valid youtube from embed" do
    yt = ExternalMedia::Youtube.create! :media_embed => SAMPLE_YOUTUBE_EMBED
    yt.should be_valid
  end
end
