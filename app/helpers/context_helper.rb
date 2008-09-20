=begin

Context
-------------------

Context refers to a container for the user's current view and actions.  For example, the list of 
pages ad /groups/x/pages has the context of group x.  A new page can also be created within this context.


##################################################################################

=end

module ContextHelper

  # returns the object scoping the current result set for list views. 
  # can return a Group, a User, the current_user, an Issue, a Tag, a Page, or a Tool::Event
  def scoped_by_context?
    context = @group || @issue || @me || @person || @tag  || @page || @event
    context unless context && context.new_record?
  end

  alias :current_context :scoped_by_context?

  # returns an array suitable for formatting in the send statement
  def context_finder(source)
    context_finder_method = case source when User; :by_person; when Group; :by_group; when Issue; :by_issue; when Tag; :by_tag; end
    return :by_tag, nil unless context_finder_method
    [ context_finder_method, source ]
  end

  def scoped_pagination_params
    scope_type = context_path_prefix_type( scoped_by_context? )
    return nil unless scope_type
    { scope_type + '_id' => scoped_by_context? }
  end

  def scoped_path( path_type, options = {} )
    action =  options.delete(:action)
    requested_scope = options.delete(:scope) || scoped_by_context?
    scope_type = context_path_prefix_type( requested_scope )
#      case scoped_by_context?
#        when Group; "group"
#        when current_user; "me"
#        when User; "person"
#        when Issue; "issue"
#        when Tag; "tag"
#        when Tool::Event; "event"
#      end
    (return self.send( ( action ? "#{action}_" : "" ) + "#{path_type}_path", options )) unless scope_type
    
    if scope_type == 'me'
      self.send( ( action ? "#{action}_" : "" ) + "#{scope_type}_#{path_type}_path", options ) 
    else
      self.send( ( action ? "#{action}_" : "" ) + "#{scope_type}_#{path_type}_path", requested_scope, options ) 
    end
  end

  def context_path_prefix_type(page_context)
    case page_context
      when Group; "group"
      when current_user; "me"
      when User; "person"
      when Issue; "issue"
      when Tag; "tag"
      when Tool::Event; "event"
    end
  
#    if page_context
#      context_url_prefix = 'group' if page_context.is_a? Group
#      context_url_prefix = 'issue' if page_context.is_a? Issue 
#      context_url_prefix = 'tag' if page_context.is_a? Tag
#      if page_context.is_a? User 
#        context_url_prefix = ( page_context == current_user) ? 'me' : 'person' 
#      end
#    else
#      context_url_prefix = nil
#    end
#    context_url_prefix
  end
end
