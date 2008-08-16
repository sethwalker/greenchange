module FixtureReplacement
  attributes_for :asset do |a|
    fixture_path = RAILS_ROOT + '/spec/fixtures/'
    a.uploaded_data         = ActionController::TestUploadedFile.new(fixture_path  + File.join('files','image.png'), 'image/png', :binary)
    
	end

  attributes_for :avatar do |a|
    
	end

  attributes_for :category do |a|
    
	end

  attributes_for :channel do |a|
    
	end

  attributes_for :channels_user do |a|
    
	end

  attributes_for :contact do |a|
    
	end

  attributes_for :discussion do |d|
    d.page                  = default_page
	end

  attributes_for :event do |a|
    
	end

  attributes_for :federation do |a|
    
	end

  attributes_for :group_participation do |a|
    
	end

  attributes_for :group do |g|
    g.name                  = String.random
	end

  attributes_for :invitation do |i|
  end

  attributes_for :issue do |i|
    i.name                  = String.random 
	end

  attributes_for :join_request do |j|
    j.sender                = default_user
    j.requestable           = default_group
  end

  attributes_for :link do |a|
    
	end

  attributes_for :membership do |a|
    
	end

  attributes_for :message do |a|
    
	end

  attributes_for :network_event do |a|
    a.action = 'create'
    a.user = default_user
    a.modified = default_page
  end

  attributes_for :page_tool do |a|
    
	end

  attributes_for :page do |p|
    p.title                 = 'atitle'
    p.created_by            = default_user
	end

  attributes_for :post do |p|
    p.body = String.random
    p.user = default_user
    p.discussion = default_discussion
	end

  attributes_for :preference do |p|

  end

  attributes_for :rating do |a|
    
	end

  attributes_for :tagging do |t|
    t.taggable_type         = 'Page'
	end

  attributes_for :tag do |t|
    t.name                  = String.random
	end

  attributes_for :user_participation do |a|
    
	end

  attributes_for :user do |u|
    u.login                 = String.random
    u.password              = 'password'
    u.password_confirmation = 'password'
    u.email                 = 'auser@email.com'
    u.private_profile       = default_profile
    u.activated_at          = 1.day.ago
    u.enabled               = true
	end

  attributes_for :profile do |p|
    p.first_name            = 'a'
    p.last_name             = 'user'
    p.friend                = true
  end

  attributes_for :wiki do |w|
    w.body                  = String.random
	end

  attributes_for :possible, :class => Poll::Possible do |p|
    p.name                  = String.random
  end
  attributes_for :subscription do |sub|
    sub.user = default_user
  end

  attributes_for :task, :class => Task::Task do |t|

  end

end
