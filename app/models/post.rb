#
# body          :text
# body_html     :text
# created_at    :datetime
# updated_at    :datetime
#

class Post < ActiveRecord::Base

  acts_as_rateable

  ## associations ############################################
  
  belongs_to :discussion, :counter_cache => true
  belongs_to :user

  ## attributes #############################################
  
  format_attribute :body
  attr_accessible :body
  
  ## validations ############################################

  validates_presence_of :discussion_id, :user_id, :body  

  ## methods ################################################

  def editable_by?(user)
    true
  end
  
  # used for default group, if present, to set for any embedded links
  def group_name
    discussion.page.group_name
  end

  after_create :notify_author
  def notify_author
    # NetworkEvent.create
    if page && page.created_by && page.created_by != user
      UserMailer.deliver_comment_posted(self) if page.created_by.receives_email_on('comments')
    end
  rescue Errno::ECONNRESET
  end

  def page
    discussion.try :page
  end
  
  after_save :index_page
  def index_page
    if page
      Page.update_all(["delta = ?", true], ["id = ?", page.id])
      page.index_delta
    end
  end

  after_destroy :toggle_deleted_page
  def toggle_deleted_page
  end
end
