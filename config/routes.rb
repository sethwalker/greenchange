ActionController::Routing::Routes.draw do |map|

  map.root    :controller => 'sessions', :action => 'new'
  map.login   '/login',   :controller => 'sessions',   :action => 'new'
  map.logout  '/logout',   :controller => 'sessions',   :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'accounts', :action => 'show'
  map.forgot_password '/forgot_password',     :controller => 'passwords',   :action =>  'new'
  map.reset_password  '/reset_password/:id',  :controller => 'passwords',   :action =>  'edit'
  map.block_email '/block_email/:retrieval_code', :controller => 'emails', :action => 'block'

  map.resource :session
  map.resource :account
  map.resource :network, :member => { :connect => :get }  do | network |
    network.resources :invitations, :controller => 'network_invitations'
  end

  map.resource :popular

  map.resources :issues

  ##### ASSET ROUTES ######################################
  
  map.with_options :controller => 'asset', :action => 'show' do | m |
    m.connect 'assets/:id/versions/:version/*filename'
    m.connect 'assets/:id/*filename'
  end

  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##### REGULAR ROUTES ####################################
  
  #map.connect 'me/inbox/*path', :controller => 'inbox', :action => 'index'
  #map.connect 'me/search/*path', :controller => 'me', :action => 'search'


  # this method adds the scope of an existing route to the page controllers
  def page_routes(parent)
    parent.with_options :member => {:version => :get, :versions => :get, :diff => :get, :break_lock => :post} do |wikis|
      wikis.resources :wikis, :controller => 'tool/wiki'
      wikis.resources :actions, :controller => 'tool/action_alert'
      wikis.resources :blogs, :controller => 'tool/blog'
      wikis.resources :news, :controller => 'tool/news'
    end
    parent.media 'media', :controller => 'tool/media', :page_type => 'media', :action => 'index'
    parent.formatted_media 'media.:format', :controller => 'tool/media', :page_type => 'media', :action => 'index'
    parent.tools 'tools', :controller => 'tool/tools', :page_type => 'tools', :action => 'index'
    parent.formatted_tools 'tools.:format', :controller => 'tool/tools', :page_type => 'tools', :action => 'index'
    parent.involvements 'involvements', :controller => 'tool/involvements', :page_type => 'involvements', :action => 'index'
    parent.formatted_involvements 'involvements.:format', :controller => 'tool/involvements', :page_type => 'involvements', :action => 'index'
    parent.updates      'updates',      :controller => 'tool/updates',      :page_type => 'updates',      :action => 'index'
    parent.formatted_updates      'updates.:format',      :controller => 'tool/updates',      :page_type => 'updates',      :action => 'index'
    parent.resources :pages do |page|
      page.icon 'icon/:size.:format', :controller => 'pages', :action => 'icon'
      page.connect 'icon.:format', :controller => 'pages', :action => 'icon'
      page.resources :bookmarks
      page.resources :recommendations
    end
    parent.resources :uploads, :controller => 'tool/asset', :member => {:destroy_version => :destroy}
    parent.resources :events, :controller => 'tool/event', :member => {:participate => :post, :set_event_description => :post}, :collection => {:day => :get, :week => :get, :month => :get, :calendar => :get} do |event|
      #event.resources :attendees
      event.resources :rsvps
      event.resources :invitations, :controller => 'event/invitations', :member => {:accept => :post, :ignore => :put}
    end
    parent.resources :videos, :controller => 'tool/external_video' #for now
    parent.resources :audio, :controller => 'tool/audio'
    parent.resources :photos, :controller => 'tool/image' 
    parent.resources :messages
    parent.resources :discussions, :controller => 'tool/discussion'
    parent.resources :polls, :controller => 'tool/ranked_vote', :member => {:add_possible => :post, :sort => :post, :update_possible => :put, :edit_possible => :get, :destroy_possible => :destroy}
    parent.resources :surveys, :controller => 'tool/rate_many', :member => {:add_possible => :post, :edit_possible => :get, :destroy_possible => :destroy, :vote_one => :post, :vote => :post, :clear_votes => :destroy, :sort => :post}
    parent.resources :tasks, :controller => 'tool/task_list', :member => {:sort => :post, :create_task => :post, :mark_task_complete => :post, :mark_task_pending => :post, :destroy_task => :destroy, :update_task => :put, :edit_task => :get} do |tasklist|
      tasklist.resources :tasks
    end

  end
  page_routes(map)

  map.resources :rsvps
  map.resources :ratings

  #map.namespace :me do |me|
    #me.network  'network', :controller => 'network'#, :me => true
    #me.events   'events'#,  :controller => 'event'#, :me => true
    #me.content  'pages', :controller => 'tool/base'
  #end

  #me routes
  map.resource :me, :controller => 'me' do |me|  
    me.resources :contacts
    me.resources :people
    me.resources :groups   
    me.resources :bookmarks
    me.resources :preferences
    page_routes me
    me.resource  :profile
    me.resources :subscription_updates
    me.resource  :network
    me.resource :inbox,   :controller => 'inbox' do |inbox|
      inbox.resources :messages 
    end
  end
  map.resources :profiles do |profile|
    profile.resources :email_addresses, :controller => 'profile/email_addresses'
    profile.resources :im_addresses, :controller => 'profile/im_addresses'
    profile.resources :phone_numbers, :controller => 'profile/phone_numbers'
    profile.resources :web_resources, :controller => 'profile/web_resources'
    profile.resources :locations, :controller => 'profile/locations'
  end
  
  map.resources :groups do |group|
    group.resources :people
    group.resources :invitations
    group.resource :feature
    group.resources :join_requests, :member => { :approve => :put, :ignore => :put }
    #group.resources :memberships, :controller => 'membership', :collection => {:join => :get, :invite => :get, :leave => :get, :send_invitation => :post }, :member => { :approve => :put, :reject => :delete, :refuse => :delete, :accept => :put, :promote => :put }
    group.resources :memberships, :member => { :promote => :put }
    #group.resource :profile, :controller => 'group/profiles'
    group.icon 'icon/:size.:format', :controller => 'groups', :action => 'icon'
    group.connect 'icon.:format', :controller => 'groups', :action => 'icon'
    group.chat 'chat', :controller => 'chat', :action => 'channel'
    page_routes(group)
  end

  #map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /tags|archive|search|calendar_month|list_by_day|list_by_week|list_by_month/
  map.resources :memberships

  map.resources :people do |person|
    person.resources :invitations
    person.resources :groups
    person.resource  :feature
    person.resources :contacts
    person.resources :bookmarks
    person.resource :profile
    person.icon 'icon/:size.:format', :controller => 'people', :action => 'icon'
    person.connect 'icon.:format', :controller => 'people', :action => 'icon'
    page_routes(person)
  end

  map.resources :tags do |tag|
    page_routes(tag)
  end

  map.resources :invitations, :member => { :accept => :put, :ignore => :put }
  map.resources :join_requests, :member => { :approve => :put, :ignore => :put } 
  #map.people 'people/:action/:id', :controller => 'people'
  #map.connect 'person/:action/:id/*path', :controller => 'person'

  map.resources :issues do |issue|
    issue.resources :people
    issue.resources :groups
    page_routes( issue )
  end
  
  #map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'
  
  map.new_media_menu 'pages/new/media', :controller => 'pages', :action => 'new_media'       
  map.new_post_menu 'pages/new/post', :controller => 'pages', :action => 'new_post'       
  map.new_tool_menu 'pages/new/tool', :controller => 'pages', :action => 'new_tool'       
  map.new_action_menu 'pages/new/action', :controller => 'pages', :action => 'new_action'    

  map.takeaction 'takeaction', :controller => 'tool/action_alert', :action => 'landing'
  map.resources :posts
  
  
  # typically, this is the default route
  map.connect ':controller/:action/:id'
 
  # a generic route for tool controllers 
  map.connect 'tool/:controller/:action/:id'

  map.exceptions 'logged_exceptions/:action/:id', :controller => 'logged_exceptions'
end

# debug routes
#ActionController::Routing::Routes.routes.each do |route|
#  puts route
#end
