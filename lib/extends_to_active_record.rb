#serialize_to and initialized_by were moved to lib/social_user.rb

ActiveRecord::Base.class_eval do
  
  # used to auto-format body  
  def self.format_attribute(attr_name)
    #class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save do |record|
      unless record.body.blank?
        record.body.strip!
        record.body_html = GreenCloth.new(record.body).to_html
      end
    end
  end
  
  def dom_id
    [self.class.name.downcase.pluralize.dasherize, id] * '-'
  end
  
  #
  # TRACK CHANGES
  #
  # it allows you to tell when an attribute has
  # been changed. example usage:
  # 
  # class User < ActiveRecord::Base
  #    track_changes :username, :password
  #    after_save :reset_changed  # if you want 
  #    def before_save
  #      if changed? :username
  #        do_something_with old_value(:username)
  #      end
  #    end
  # end
  #
  # TODO: track changes currenlty only works with simple attributes,
  #       not with associations!!!
  #
  # this code is here because originally the acts_as_modified plugin
  # did not work with ruby 1.8. I wrote to the author about this and
  # he released a new versions that works with 1.8. So, there we should
  # probably eliminate this code and just use the plugin:
  # 
  # http://svn.viney.net.nz/things/rails/plugins/acts_as_modified/
  # 
  # This plugin is currently installed and used by some models.
  #
#  def self.track_changes(*attr_names)
#    attr_names.each do |attr_name|
#      define_method "#{attr_name}=" do |value|
#        write_changed_attribute attr_name.to_sym, value
#      end
#    end
#  end
#
#  def changed
#    @changed || reset_changed
#  end
#
#  def reset_changed
#    @changed = Hash.new(false)
#  end
#  
#  def old_value(key)
#    changed[key.to_sym]
#  end
#  
#  def write_changed_attribute(attr_name, value)
#    old_value = self.send(attr_name)
#    write_attribute attr_name, value
#    changed[attr_name.to_sym] = old_value if self.send(attr_name) != old_value
#  end
#    
#  def changed?(attr_name = nil)
#    return changed.any? unless attr_name
#    begin
#      changed.fetch(attr_name.to_sym)
#      return true
#    rescue IndexError
#      return false
#    end
#  end
#

end
