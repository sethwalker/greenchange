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
      else
        resource_name
    end
  end

  def list_languages( languages )
    language_lookup = Hash[ *ProfileHelper::LANGUAGES.flatten]
    languages.map { |lang| language_lookup[ lang.language ] }.join( ', ' )
  end

  

  def photo(profile)
    avatar_for(profile.entity, 'xlarge')
  end

  def random_dom_id
    rand(10**10)
  end
  
  def remove_link(dom_id)
    "<span class='remove'>%s</span>" % link_to_function('remove', "Element.remove($('#{dom_id}'))")
  end    
  
  def add_row_link(title,action)
    link_to_remote title, :url => {:controller => :profile, :action => action}
  end
  
  
  # set the clicked star in a 'radio-button'-like group to selected
  # sets a hidden field with the value of true/false
  def mark_as_primary(object, object_name, method_name, index)
    content = ''

    id              = "#{object_name}_#{method_name}_#{index}_preferred"
    name            = "#{object_name}[#{method_name.pluralize}][#{index}][preferred]"
    collection_name = "#{object_name}_#{method_name.pluralize}" # the stars must be in a tbody with this id

    if object.preferred?
      content << "<div id='#{id + '_div'}' title='Currently marked as primary' class='primaryItem'>"
      content << "<input type='hidden' value='true' id='#{id}' name='#{name}' />"
      content << "</div>"
    else
      content << "<div id='#{id + '_div'}' title='Mark as primary' class='makePrimaryItem'>"
      content << "<input type='hidden' value='false' id='#{id}' name='#{name}' />"
      content << "</div>"
    end
    content << javascript_tag("Event.observe('#{id + '_div'}', 'click', function(event){People.markAsPrimary('#{id + '_div'}', '#{collection_name}');});")

    content
  end
  
  def select_tag_with_id(name, option_tags = nil, options = {})
    tag_id = options.has_key?(:id) ? options[:id] : name
    content_tag :select, option_tags, { "name" => name, "id" => tag_id }.update(options.stringify_keys)
  end
end
