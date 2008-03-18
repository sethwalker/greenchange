# 
# Where do pages come from? The PageStork, of course!
# Here in lies all the reusable macros for creating complex pages
#

class PageStork

  def self.wiki(options)
    user = (options.delete(:user).cast! User if options[:user])
    group = options.delete(:group).cast! Group
    name = options.delete(:name).cast! String
    page = Tool::TextDoc.new do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
    end
    page.save
    page.add(group)
    if options[:body]
      page.data = Wiki.new(:body => options[:body], :page => page)
    end
    return page
  end
  
  def self.private_message(options) 
    from = options.delete(:from).cast! User 
    to = options.delete(:to) 
    page = Tool::Message.new do |p| 
      p.title = options[:title] || 'Message from %s to %s' % [from.login, to.login] 
      p.created_by = from 
    end
    page.save!
    page.discussion = Discussion.create

    new_post = Post.new :body => options[:body]
    new_post.user = from
    new_post.discussion = page.discussion
    new_post.save
    page.discussion(true)


    page.add(from, :access => :admin) 
    page.add(to, :access => :admin) 
    page 
  end
  
	def self.event(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    page = Tool::Event.new do |e|
	e.title = options[:title]
	e.created_by = user
    end
    page.save
    page.add(group)
    page
  end
	
end

