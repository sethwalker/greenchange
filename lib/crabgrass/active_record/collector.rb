module Crabgrass
  module ActiveRecord
    module Collector
      def self.included(base)
        base.cattr_accessor :collections
        base.extend ClassMethods
        base.after_create :initialize_collections
      end
      
      module ClassMethods
        def has_collections(*args)
          self.collections ||= {}
          args.each do |collection_name|
            collection_accessor = "#{collection_name}_collection".to_sym
            self.collections[collection_name] = collection_accessor
            self.has_one collection_accessor, :conditions => "permission = '#{collection_name}'", :class_name => "Collection", :dependent => :destroy
          end
        end
      end

      def initialize_collections
        return unless defined? self.class.collections
        self.class.collections.each do |name, accessor|
          unless send(accessor) 
            create_method = "create_#{accessor}".to_sym
            send create_method, :permission => name.to_s
            send( accessor ).save!
          end
        end
      end

    end
  end
end
