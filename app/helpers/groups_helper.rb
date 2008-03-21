module GroupsHelper

  include WikiHelper
  
  def more_members_link( html_options = {} )
    link_to 'view all'.t, url_for(:controller => 'membership', :action => 'list', :id => @group), html_options
  end
  
  def invite_link( html_options = {} )
    if current_user.may_admin?(@group)
      link_to 'send invites'.t, url_for(:controller => 'membership', :action => 'invite', :id => @group), html_options
    end
  end

  def requests_link( html_options = {} )
    if current_user.may_admin?(@group)
      link_to 'view requests'.t, url_for(:controller => 'membership', :action => 'requests', :id => @group), html_options
    end
  end
end
