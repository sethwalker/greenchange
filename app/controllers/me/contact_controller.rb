#
# manage the users own contacts
#

class Me::ContactController < ContactController

  prepend_before_filter :fetch_person

  protected

  def fetch_person
    @person = current_user
  end
  
end

