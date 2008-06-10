module ProfileHelper
  NOTES = Crabgrass::Config.profile_note_types.map(&:first)
  NOTE_TYPE_NAMES = Hash[ *Crabgrass::Config.profile_note_types.flatten ]
  EMAIL_TYPES = { 
    'personal' => 'Personal',
    'work' =>  'Work',
    'school' => 'School',
    'other'  => 'Other'
    }

  PHONE_TYPES = %w[Home Fax Mobile Other Pager Work]
  LOCATION_TYPES = %w[Home Work School Other]
  LANGUAGES = [
    ['ar', 'Arabic'],
    ['bn', 'Bengali; Bangla'],
    ['en', 'English'],
    ['fr', 'French'],
    ['de', 'German'],
    ['el', 'Greek'],
    ['he', 'Hebrew'],
    ['hi', 'Hindi'],
    ['ja', 'Japanese'],
    ['jw', 'Javanese'],
    ['ko', 'Korean'],
    ['zh', 'Mandarin'],
    ['mr', 'Marathi'],
    ['fa', 'Persian'],
    ['pt', 'Portuguese'],
    ['ru', 'Russian'],
    ['es', 'Spanish'],
    ['sw', 'Swahili'],
    ['ta', 'Tamil'],
    ['te', 'Telugu'],
    ['bo', 'Tibetan'],
    ['vi', 'Vietnamese'],
  ]

  HCARD_CONTACT_TYPES = { 'Mobile' => 'cell', 'Pager' => 'pgr', 'Personal' => 'home', 'personal' => 'home' }

  def hcard_data_type( type )
    HCARD_CONTACT_TYPES[type] ? HCARD_CONTACT_TYPES[type] : type.downcase
  end

  IM_TYPES =
    ['Jabber', 'IRC', 'Silc', 'Gizmo', 'AIM',
    'Google Talk', 'MSN', 'Skype', 'Yahoo', 'Other']

  def hcard_im_url( type, address )
    case type
      when 'AIM'
        "aim:goim?screenname=#{address}"
      when 'Yahoo'
        "ymsgr:sendIM?#{address}"
      when 'MSN'
        "msnim:chat?contact=#{address}"
      when 'Jabber'
        "xmpp:#{address}"
      when 'Skype'
        "skype:#{address}?chat"
      when 'ICQ'
        #note: ICQ also requires the link to have attribute type='application/x-icq'
        "http://www.icq.com/people/cmd.php?uin=#{address}&action=message"
    end
  end

  WEB_RESOURCE_TYPES =
    {'blog' => 'My blog URL',
    'facebook' => 'Facebook profile URL',
    'linkedin' => 'LinkedIn profile URL',
    'myspace' => 'MySpace profile URL',
    'youtube' => 'You Tube username',
    'flickr' => 'Flickr feed',
    'last.fm' => 'Last.fm username',
    'del.icio.us' => 'de.icio.us username',
    'twitter' => 'Twitter username',
    'blip' => 'Blip.tv username'  
  }

  def web_resource_url( type, resource_name )
    return resource_name if resource_name =~ /^(http|https):\/\/[a-z0-9]+([-.]{1}[a-z0-9]+)*.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
    case type
      when 'youtube'
        "http://youtube.com/profile?user=#{resource_name}"
      when 'last.fm'
        "http://www.last.fm/user/#{resource_name}"
      when 'del.icio.us'
        "http://del.icio.us/#{resource_name}"
      when 'twitter'
        "http://twitter.com/#{resource_name}"
      when 'blip'
        "http://#{resource_name}.blip.tv"
    end
  end

  def list_languages( languages )
    language_lookup = Hash[ *ProfileHelper::LANGUAGES.flatten]
    languages.map { |lang| language_lookup[ lang.language ] }.join( ', ' )
  end
end
