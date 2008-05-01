=begin

Context
-------------------

Context is the general term for information on where we are and how we got here.
This includes breadcrumbs and banner, although each work differently. 

The banner is based on the context. For example, the context might be 'groups > 
rainbow > my nice page'. 

Sometimes the breadcrumbs are based on the context, and sometimes they are not. 
Typically, breadcrumbs are based on the context for non-page controllers. For a 
page controller (ie tool) the breadcrumbs are based on the breadcrumbs of the 
referer (if it exists) or on the primary creator/owner of the page (otherwise). 
Breadcrumbs based on the referer let us show how we got to a page, and also show
a canonical context for the page (via the banner). 

The breadcrumbs of the referer are stored in the session. This might result in 
bloated session data, but I think that a typical user will have a pretty finite 
set of referers (ie places they loaded pages from). 

##################################################################################

this module is included in application.rb
=end

module ContextHelper

  # returns the object scoping the current result set for list views. 
  # TODO: should return false if there is no nested scope, true if the scope exists but cannot be determined
  def scoped_by_context?
    @group || @issue || @me || @person || @tag  || @page
  end

  # returns an array suitable for formatting in the send statement
  def context_finder(source)
    context_finder_method = case source when User; :by_person; when Group; :by_group; when Issue; :by_issue; when Tag; :by_tag; end
    return :by_tag, nil unless context_finder_method
    [ context_finder_method, source ]
  end

end
