#
#
# NOTE: make sure to update the validates_handle function whenever you add a new controller
# or a new root path route. This way, group and user handles will not be created for those
# (group name or user login are used as the :context in the default route, so it can't collide
# with any of our other routes).
# 

ActionController::Routing::Routes.draw do |map|

  map.resources :bookmarks, :belongs_to => :page
  map.resources :issues
  

  ##### ASSET ROUTES ######################################
  
  map.with_options :controller => 'asset', :action => 'show' do |m|
    m.connect 'assets/:id/versions/:version/*filename'
    m.connect 'assets/:id/*filename'
  end

  # unobtrusive javascript
  #UJS::routes
  
  # bundled_assets plugin:
  map.connect 'bundles/:version/:names.:ext', :controller => 'assets_bundle', :action => 'fetch', :ext => /css|js/, :names => /[^.]*/
  
  map.avatar 'avatars/:id/:size.jpg', :action => 'show', :controller => 'avatars', :defaults => {:id => "images/default"}
  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##### REGULAR ROUTES ####################################
  
  #map.connect 'me/inbox/*path', :controller => 'inbox', :action => 'index'
  #map.connect 'me/search/*path', :controller => 'me', :action => 'search'


  # this method adds the scope of an existing route to the page controllers
  def page_routes(parent)
    parent.with_options :member => {:version => :get, :versions => :get, :diff => :get, :break_lock => :post, :print => :get} do |wikis|
      wikis.resources :wikis, :controller => 'tool/wiki'
      wikis.resources :actions, :controller => 'tool/action_alert'
      wikis.resources :blogs, :controller => 'tool/blog'
      wikis.resources :news, :controller => 'tool/news'
    end
    parent.media 'media', :controller => 'tool/media', :page_type => 'media', :action => 'index'
    parent.tools 'tools', :controller => 'tool/tools', :page_type => 'tools', :action => 'index'
    parent.involvements 'involvements', :controller => 'tool/involvements', :page_type => 'involvements', :action => 'index'
    parent.updates 'updates', :controller => 'tool/updates', :page_type => 'updates', :action => 'index'
    parent.resources :pages
    parent.resources :uploads, :controller => 'tool/asset', :member => {:destroy_version => :destroy}
    parent.resources :events, :controller => 'tool/event', :member => {:participate => :post, :set_event_description => :post}, :collection => {:day => :get, :week => :get, :month => :get, :calendar => :get}
    parent.resources :videos, :controller => 'tool/external_video' #for now
    parent.resources :audio, :controller => 'tool/audio'
    parent.resources :photos, :controller => 'tool/image' 
    parent.resources :messages, :controller => 'tool/message'
    parent.resources :discussions, :controller => 'tool/discussion'
    parent.resources :polls, :controller => 'tool/ranked_vote', :member => {:add_possible => :post, :sort => :post, :update_possible => :put, :edit_possible => :get, :destroy_possible => :destroy}
    parent.resources :surveys, :controller => 'tool/rate_many', :member => {:add_possible => :post, :edit_possible => :get, :destroy_possible => :destroy, :vote_one => :post, :vote => :post, :clear_votes => :destroy, :sort => :post}
    parent.resources :tasks, :controller => 'tool/task_list', :member => {:sort => :post, :create_task => :post, :mark_task_complete => :post, :mark_task_pending => :post, :destroy_task => :destroy, :update_task => :put, :edit_task => :get} do |tasklist|
      tasklist.resources :tasks
    end

  end
  page_routes(map)


  
  #me routes
  #map.resource :profile
  map.namespace :me do |me|
    me.namespace :profile do |profile|
      profile.resources :email_addresses
      profile.resources :im_addresses
      profile.resources :phone_numbers
      profile.resources :websites
      profile.resources :locations
    end
    me.resource :profile
    me.network  'network', :controller => 'network'#, :me => true
    #me.events   'events'#,  :controller => 'event'#, :me => true
    #me.content  'pages', :controller => 'tool/base'
    me.resources :contacts, :controller => 'contact', :member => { :approve => :post, :reject => :post, :add => :get }
  end
  #map.resource :profile, :controller => 'profiles', :path_prefix => 'me/', :name_prefix => 'my'
  map.resource :me, :controller => 'me', :member => { :search => :get, :files => :get, :tasks => :get } do |me|  
    me.resource :inbox,   :controller => 'inbox' do |inbox|
      inbox.resources :messages 
    end
    me.resources :people
    me.resources :groups   
    page_routes me
  end
    #me.inbox 'inbox/:path', :controller => 'inbox', :action => 'index'
    #me.inbox 'inbox', :controller => 'inbox', :action => 'index'
    #me.resource :profile, :controller => 'profiles'#, :me => true #, :action => 'show'
    #me.requests 'requests/:action/*path', :controller => 'requests'
    #me.network 'network', :controller => 'network', :me => true
    #me.content 'content', :controller => 'tool/base', :me => true
    #me.events 'events', :controller => 'tool/event', :me => true
  #end
  
  #map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /tags|archive|calendar|search/

  map.resources :groups, :member => {:search => :get, :requests => :get, :edit_profile => :any} do |group|
    group.resources :people
    group.resources :memberships, :controller => 'membership', :collection => {:join => :get, :invite => :get, :leave => :get, :send_invitation => :post }, :member => { :approve => :put, :reject => :delete, :refuse => :delete, :accept => :put }
    group.resource :profile, :controller => 'group/profiles'
    group.chat 'chat', :controller => 'chat', :action => 'channel'
    page_routes(group)
  end
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /tags|archive|search|calendar_month|list_by_day|list_by_week|list_by_month/
  map.resources :memberships, :collection => {:join => :get, :invite => :get, :leave => :get}

  map.resources :people, :member => {:search => :get, :requests => :get, :edit_profile => :any} do |person|
    person.resources :memberships, :collection => {:join => :get, :invite => :get, :leave => :get, :approve => :put }
    person.resources 'contacts', :controller => 'contact'#, :member => { :approve => :post, :reject => :post }
    person.resource :profile, :controller => 'people/profiles'
    page_routes(person)
  end

  map.people 'people/:action/:id', :controller => 'people'
  map.connect 'person/:action/:id/*path', :controller => 'person'

  map.resources :issues do |issue|
    issue.resources :people
    issue.resources :groups
    page_routes( issue )
  end
  
  map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'
  
  map.new_media_menu 'pages/new/media', :controller => 'pages', :action => 'new_media'       
  map.new_post_menu 'pages/new/post', :controller => 'pages', :action => 'new_post'       
  map.new_tool_menu 'pages/new/tool', :controller => 'pages', :action => 'new_tool'       
  map.new_action_menu 'pages/new/action', :controller => 'pages', :action => 'new_action'    

  map.takeaction 'takeaction', :controller => 'tool/action_alert', :action => 'landing'
  map.resources :posts
  
  
     
  map.connect '', :controller => "account"
  map.resource :account, :controller => 'account', :member => { :signup => :get }
  map.login   'account/login',   :controller => 'account',   :action => 'login'
  map.forgot_password '/forgot_password',     :controller => 'passwords',   :action =>  'new'
  map.reset_password  '/reset_password/:id',  :controller => 'passwords',   :action =>  'edit'
  
  # typically, this is the default route
  map.connect ':controller/:action/:id'
 
  # a generic route for tool controllers 
  map.connect 'tool/:controller/:action/:id'

  #### RESTFUL ROUTES #######################################
  map.resources :collectings
  map.resources :collections

  map.exceptions 'logged_exceptions/:action/:id', :controller => 'logged_exceptions'
end

# debug routes
#ActionController::Routing::Routes.routes.each do |route|
#  puts route
#end
