module DemocracyInAction
  module Tables
    module Attributes
      def self.included(base)
        base.cattr_accessor :columns
      end

      def name
        self.class.to_s.gsub(/^.*::/, '').downcase #demodulize
      end
    end
  end
end
