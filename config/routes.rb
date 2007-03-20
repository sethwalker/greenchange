ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'show'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # :defaults => {:file => nil},
  # :requirements => {:file => %r{[^/]+(\.[^/]+)?}}
  
  # perhaps use nested routes instead?
  # http://www.artofmission.com/articles/2006/10/12/nested-routes-using-map-resources
  
  # PAGE_TYPES are hardcoded in environment.rb
  for page in PAGE_TYPES
    map.connect ":from/:from_id/#{page}/:action/:id",
     :from => /groups|me|people|networks|places/,
     :controller => "tool/#{page}",
     :action => 'show'
  end

  map.connect 'me/folder/*path', :controller => 'me', :action => 'folder'
  map.me 'me/:action/:id', :controller => 'me'
  
  map.people 'people/:action/:id', :controller => 'people'
  map.person 'people/:action/:id', :controller => 'people'
  map.connect 'people/:id/folder/*path', :controller => 'people', :action => 'folder'
  
  map.groups 'groups/:action/:id', :controller => 'groups'
  map.group  'groups/:action/:id', :controller => 'groups'
  map.connect 'groups/:id/folder/*path', :controller => 'groups', :action => 'folder'
    
  map.avatar 'avatars/:id/:size.jpg', :action => 'show', :controller => 'avatars'
  
  map.connect '', :controller => "account"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
