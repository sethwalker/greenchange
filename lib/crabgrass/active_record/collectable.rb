module Crabgrass
  module ActiveRecord
    module Collectable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def is_collectable
          #self.has_many :collections, :through => :collectings
          #self.has_finder :allowed, &:allowed?
        end
      end
      
      def allowed?( user, perm = :view )
        
      end 

    end
  end
end
