class Discussion < ActiveRecord::Base

  ## associations ###########################################
  
  belongs_to :page
    
  # relationship with posts   
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy, :class_name => '::Post' do
    def last
      @last_post ||= find(:first, :order => 'posts.created_at desc')
    end
  end

  has_many :participants, :class_name => 'User', :through => :posts, :source => :user

   
  ## attributes ############################################# 

  # to help with the create form
  attr_accessor :body, :new_post
  def new_post=(values)
    @new_post =  ::Post.new( values ) if values.any? { |key, v| !v.blank? }
    # this lines courtesey of attr_accessible ...
    @new_post.user_id = values[:user_id] if values[:user_id]
  end

  ## validations ############################################



  ## callbacks ##############################################

  before_create { |r| r.replied_at = Time.now.utc }
#  after_save    { |r| Post.update_all ['forum_id = ?', r.forum_id], ['topic_id = ?', r.id] }
  after_save :new_post_save
  def new_post_save
    #raise 'yo bi ath'
    if @new_post
      @new_post.discussion = self
      @new_post.save 
    end
    posts(true)
  end

  ## methods ################################################
  
  def per_page; 20; end
 
  # don't know why i can't get posts_count to be correct value
  # for now, we use posts.count
  def paged?() posts.count > per_page end
  
  def last_page
    posts.count > 0 ? (posts.count.to_f / per_page.to_f).ceil.to_i : nil
  end

#  def editable_by?(user)
#    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
#  end
  
end
