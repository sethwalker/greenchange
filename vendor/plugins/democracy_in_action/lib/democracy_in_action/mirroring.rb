# note:
# possible to have a multiple mirrorings per class?  model.democracy_in_action[key].mappings
module DemocracyInAction
  module Mirroring

    def self.auth
      DemocracyInAction::Auth
    end

    def self.api
      @@api ||= DemocracyInAction::API.new 'authCodes' => [auth.username, auth.password, auth.org_key]
    end

    # can currently do more than one table per model, as long as all of the tables are unique
    def self.mirror(table, model, &block)
      Mirror.new(table, model, &block)
    end

    class Mirror
      attr_reader :mappings, :table

      def initialize(table, model, &block)
        @guard = nil
        @mappings = {}

        raise 'no table given' if table.to_s.empty?
        @table = DemocracyInAction::Tables.const_get(table.to_s.gsub(/(^|_)(.)/) { $2.upcase }).new

        instance_eval(&block) if block_given?

        require 'democracy_in_action/mirroring/active_record' #to avoid a warning
        model.__send__ :include, DemocracyInAction::Mirroring::ActiveRecord unless model.included_modules.include?(DemocracyInAction::Mirroring::ActiveRecord)
        model.democracy_in_action.mirrors << self
      end

      # returns a hash of 'Democracy_In_Action_Column_Name' => value
      def mappings(model)
        @mappings.inject({}) do |fields, (field, map)|
          if map.is_a?(Proc)
            value = map.call(model)
            fields[field] = value if value
#            fields[field] = value unless (value.respond_to?(:empty?) ? value.empty? : !value) #blank?
          else
            fields[field] = map
          end
          fields
        end
      end

      def guard(&block)
        @guard = block if block_given?
        @guard
      end

      def map(column, value=nil, &block)
        @mappings[column] = block if block_given?
        @mappings[column] = value if value
        @mappings[column]
      end

      def defaults(attributes)
        attributes.inject({}) do |defaults, (key, value)|
          key = key.to_s.titleize.gsub(' ', '_')
          defaults[key] = value if table.columns.include?(key)
          defaults
        end
      end

    end
  end
end
