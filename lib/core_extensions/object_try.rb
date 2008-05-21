class Object
  ##
  #   @person ? @person.name : nil
  # becomes
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end

