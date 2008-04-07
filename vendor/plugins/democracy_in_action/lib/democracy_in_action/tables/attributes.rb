module DemocracyInAction
  module Tables
    module Attributes
      def self.included(base)
        base.cattr_accessor :columns
      end

      def name
        self.class.to_s.gsub(/^.*::/, '').  #demodulize
          gsub(/([a-z\d])([A-Z])/,'\1_\2'). #underscore
          downcase
      end
    end
  end
end
