#
#
# NOTE: make sure to update the validates_handle function whenever you add a new controller
# or a new root path route. This way, group and user handles will not be created for those
# (group name or user login are used as the :context in the default route, so it can't collide
# with any of our other routes).
# 

ActionController::Routing::Routes.draw do |map|
  map.resources :bookmarks, :belongs_to => :page
  

  ##### ASSET ROUTES ######################################
  
  map.with_options :controller => 'asset', :action => 'show' do |m|
    m.asset_version 'assets/:id/versions/:version/*filename'
    m.assets 'assets/:id/*filename'
  end

  # unobtrusive javascript
  #UJS::routes
  
  # bundled_assets plugin:
  map.connect 'bundles/:version/:names.:ext', :controller => 'assets_bundle', :action => 'fetch', :ext => /css|js/, :names => /[^.]*/
  
  map.avatar 'avatars/:id/:size.jpg', :action => 'show', :controller => 'avatars'
  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##### REGULAR ROUTES ####################################
  
  map.connect 'me/requests/:action/*path', :controller => 'requests'
  map.connect 'me/inbox/*path', :controller => 'inbox', :action => 'index'
  map.connect 'me/search/*path', :controller => 'me', :action => 'search'
  map.me 'me/:action/:id', :controller => 'me'
  
  map.people 'people/:action/:id', :controller => 'people'
  map.connect 'person/:action/:id/*path', :controller => 'person'
  
  map.groups  'groups/:action/:id', :controller => 'groups'
  map.group   'groups/:action/:id', :controller => 'groups'
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /tags|archive|calendar|search/
    
  map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'
            
  map.connect '', :controller => "account"
  map.login   'account/login',   :controller => 'account',   :action => 'login'
  map.forgot_password '/forgot_password',     :controller => 'passwords',   :action =>  'new'
  map.reset_password  '/reset_password/:id',  :controller => 'passwords',   :action =>  'edit'
  
  # typically, this is the default route
  map.connect ':controller/:action/:id'
 
  # a generic route for tool controllers 
  map.connect 'tool/:controller/:action/:id'

  map.with_options :member => {:version => :get, :versions => :get, :diff => :get, :break_lock => :post, :print => :get} do |wikis|
    wikis.resources :wikis, :controller => 'tool/wiki'
    wikis.resources :actions, :controller => 'tool/action_alert'
    wikis.resources :blogs, :controller => 'tool/blog'
    wikis.resources :news, :controller => 'tool/news'
  end
  map.resources :assets, :controller => 'tool/asset', :member => {:destroy_version => :destroy}
  map.resources :events, :controller => 'tool/event', :member => {:participation => :post, :set_event_description => :post}
  map.resources :videos, :controller => 'tool/external_video' #for now
  map.resources :messages, :controller => 'tool/message'
  map.resources :polls, :controller => 'tool/ranked_vote', :member => {:add_possible => :post, :sort => :post, :update_possible => :put, :edit_possible => :get, :destroy_possible => :destroy}
  map.resources :surveys, :controller => 'tool/rate_many', :member => {:add_possible => :post, :edit_possible => :get, :destroy_possible => :destroy, :vote_one => :post, :vote => :post, :clear_votes => :destroy, :sort => :post}
  map.resources :tasks, :controller => 'tool/tasklist', :member => {:sort => :post, :create_task => :post, :mark_task_complete => :post, :mark_task_pending => :post, :destroy_task => :destroy, :update_task => :put, :edit_task => :get}

  ##### DISPATCHER ROUTES ###################################
  
  # our default route is sent to the dispatcher
  map.connect 'page/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil

  #### RESTFUL ROUTES #######################################
  map.resources :collectings
  map.resources :collections
end

# debug routes
#ActionController::Routing::Routes.routes.each do |route|
#  puts route
#end
