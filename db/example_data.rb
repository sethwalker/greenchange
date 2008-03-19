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

  attributes_for :discussion do |a|
    
	end

  attributes_for :event do |a|
    
	end

  attributes_for :federation do |a|
    
	end

  attributes_for :group_participation do |a|
    
	end

  attributes_for :group do |g|
    g.name                  = 'grouply'
	end

  attributes_for :link do |a|
    
	end

  attributes_for :membership do |a|
    
	end

  attributes_for :message do |a|
    
	end

  attributes_for :page_tool do |a|
    
	end

  attributes_for :page do |p|
    p.title                 = 'atitle'
	end

  attributes_for :post do |a|
    
	end

  attributes_for :rating do |a|
    
	end

  attributes_for :tagging do |t|
    t.taggable_type         = 'Page'
	end

  attributes_for :tag do |a|
    
	end

  attributes_for :user_participation do |a|
    
	end

  attributes_for :user do |u|
    u.login                 = String.random
    u.password              = 'password'
    u.password_confirmation = 'password'
    u.email                 = 'auser@email.com'
    u.profiles              = [default_profile]
	end

  attributes_for :profile do |p|
    p.first_name            = 'a'
    p.last_name             = 'user'
    p.friend                = true
  end

  attributes_for :wiki do |a|
    
	end

  attributes_for :possible, :class => Poll::Possible do |p|
    p.name                  = String.random
  end
end
