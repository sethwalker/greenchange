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
  
  map.avatar 'avatars/:id/:size.jpg', :action => 'show', :controller => 'avatars', :defaults => {:id => "images/default"}
  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##### REGULAR ROUTES ####################################
  
  map.connect 'me/requests/:action/*path', :controller => 'requests'
  map.connect 'me/inbox/*path', :controller => 'inbox', :action => 'index'
  map.connect 'me/search/*path', :controller => 'me', :action => 'search'
  map.resource :profile
  map.me 'me/:action/:id', :controller => 'me'
  
  def page_routes(parent)
    parent.with_options :member => {:version => :get, :versions => :get, :diff => :get, :break_lock => :post, :print => :get} do |wikis|
      wikis.resources :wikis, :controller => 'tool/wiki'
      wikis.resources :actions, :controller => 'tool/action_alert'
      wikis.resources :blogs, :controller => 'tool/blog'
      wikis.resources :news, :controller => 'tool/news'
    end
    parent.media 'media', :controller => 'tool/base', :page_type => 'media', :action => 'index'
    parent.tools 'tools', :controller => 'tool/base', :page_type => 'tools', :action => 'index'
    parent.involvements 'involvements', :controller => 'tool/base', :page_type => 'involvements', :action => 'index'
    parent.updates 'updates', :controller => 'tool/base', :page_type => 'updates', :action => 'index'

    parent.resources :assets, :controller => 'tool/asset', :member => {:destroy_version => :destroy}
    parent.resources :events, :controller => 'tool/event', :member => {:participate => :post, :set_event_description => :post}, :collection => {:day => :get, :week => :get, :month => :get, :calendar => :get}
    parent.resources :videos, :controller => 'tool/external_video' #for now
    parent.resources :messages, :controller => 'tool/message'
    parent.resources :discussions, :controller => 'tool/discussion'
    parent.resources :polls, :controller => 'tool/ranked_vote', :member => {:add_possible => :post, :sort => :post, :update_possible => :put, :edit_possible => :get, :destroy_possible => :destroy}
    parent.resources :surveys, :controller => 'tool/rate_many', :member => {:add_possible => :post, :edit_possible => :get, :destroy_possible => :destroy, :vote_one => :post, :vote => :post, :clear_votes => :destroy, :sort => :post}
    parent.resources :tasks, :controller => 'tool/tasklist', :member => {:sort => :post, :create_task => :post, :mark_task_complete => :post, :mark_task_pending => :post, :destroy_task => :destroy, :update_task => :put, :edit_task => :get}
  end

  map.resources :groups, :member => {:search => :get, :requests => :get, :edit_profile => :any} do |group|
    group.resources :memberships, :collection => {:join => :get, :invite => :get, :leave => :get}
    group.resources :pages
    page_routes(group)
  end
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /tags|archive|search|calendar_month|list_by_day|list_by_week|list_by_month/
  map.resources :memberships, :collection => {:join => :get, :invite => :get, :leave => :get}
  page_routes(map)

  map.resources :people, :member => {:search => :get, :requests => :get, :edit_profile => :any} do |person|
    person.resources :memberships, :collection => {:join => :get, :invite => :get, :leave => :get}
    person.resources :pages
    page_routes(person)
  end

  map.people 'people/:action/:id', :controller => 'people'
  map.connect 'person/:action/:id/*path', :controller => 'person'
  
  map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'
            
  map.connect '', :controller => "account"
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
end

# debug routes
#ActionController::Routing::Routes.routes.each do |route|
#  puts route
#end
