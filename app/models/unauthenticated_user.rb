class UnauthenticatedUser
  def id
    raise PermissionDenied
  end

  def may?(action, resource)
    if self.respond_to?(method = "may_#{action}?")
      return self.send(method, resource)
    elsif resource.respond_to :allows?
      return resource.allows?(self, action)
    end

    false
  end

  def may_view?(resource)
    return false if resource.nil?

    if resource.respond_to? :public?
      return resource.public?
    elsif resource.respond_to :allows?
      return resource.allows?(self, action)
    end
    return false
  end
  alias :may_read? :may_view?

  def may_delete?(resource)
    false
  end
  alias :may_remove? :may_delete?

  def member_of?(group)
    false
  end

  def direct_member_of?(group)
    false
  end

  def superuser?
    false
  end

  def method_missing(method, *args)
    if method.to_s =~ /^may_([^\?!]+)([\?!]*)$/
      act = $1
      on = args[0]

      case $2 
        when '?'
          return false
        when '!'
          raise PermissionDenied, "#{self.class} is not allowed to #{act} #{on.class}"
      end
    end

    raise NoMethodError, "undefined method '#{method}' on #{self.class}"
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
