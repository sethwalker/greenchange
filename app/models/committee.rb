class Committee < Group
  before_save :update_parent
  
  # NAMING
  # the name of a committee includes the name of the parent, 
  # so the committee names are unique. however, for display purposes
  # we want to just display the committee name without the parent name.
  
  # parent name + committee name
  # over time we should move parent name into its own column and use the combined name for display
  def full_name
    names = [ ]
    names << parent_name if parent_name
    names << short_name if short_name
    names.join "+"
  end
  alias :name :full_name

  # committee name without parent
  def short_name
    read_attribute(:name)
  end

  # what we show to the user
  def display_name
    read_attribute(:display_name) || short_name
  end
        
  #has_many :delegations, :dependent => :destroy
  #has_many :groups, :through => :delegations
  #def group()
  #  groups.first if groups.any?
  #end

  # called at save and when parent saves
  def update_parent(p=nil)
    p ||= self.parent
    self.parent_name = p.full_name unless parent_name == p.full_name if p
  end
  
  # custom name setter so that we can ensure that the parent's
  # name is part of the committee's name.
  def name=(str)
    if parent
      name_without_parent = str.sub(/^#{parent.name}\+/,'').gsub('+','-')
      write_attribute(:name, name_without_parent)
    else
      write_attribute(:name, str.gsub('+','-'))
    end
  end
  alias_method :short_name=, :name=
  
  # custom setter so that we can ensure that the the committee's
  # name includes the parent's name.
  def parent=(p)
    update_parent p
    super p
  end

end
