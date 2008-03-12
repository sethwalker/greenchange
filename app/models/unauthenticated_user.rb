class UnauthenticatedUser
  def may?(perm, page)
    if self.respond_to?(method = "may_#{perm}?")
      return self.send(method, page)
    end
    false
  end

  def may_view?(page)
    return page.public?
  end
  alias :may_read? :may_view?

  def member_of?(group)
    false
  end

  def superuser?
    false
  end

  def method_missing(method, *args)
    return false if method.to_s =~ /^may/
    raise PermissionDenied
  end

  def contacts
    BlankAssociation.new
  end
  alias :groups :contacts

  class BlankAssociation < Array
    def find( *args )
      return nil unless ( args[0] == :all )
      []
    end
  end
end
