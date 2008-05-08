class ActiveRecord::Base#.class_eval do
  def self.polymorphic_attr( base_attr, options = {} )
    return unless options[:as]
    attr_types = options[:as].is_a?(Array) ? options[:as] : [ options[:as] ]
    attr_class_options = options[:class_names] || {}
    attr_classes = Hash[*attr_types.map { |attr_as| [ attr_as, (attr_class_options[attr_as] || Object.const_get(attr_as.to_s.classify)) ] }.flatten]
    
    attr_types.each do |attr_as|
      define_method("#{attr_as}?") { self.send(base_attr) and self.send(base_attr).is_a?(Object.const_get(attr_as.to_s.classify)) }
      define_method("#{attr_as}")  { self.send("#{attr_as}?") ? self.send(base_attr) : nil }
      define_method( "#{attr_as}=" ) { |value| self.send("#{base_attr}=", value ) }
      define_method( "#{attr_as}_id=" ) { |value| self.send("#{base_attr}_id=", value ); self.send("#{base_attr}_type=", attr_as.to_s.classify ) }
      define_method( "#{attr_as}_id" ) { self.send("#{base_attr}_id" ); }
    end
  end
end

