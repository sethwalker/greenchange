module DemocracyInAction
  module Mirroring
    module ActiveRecord

      def self.included(base)
        base.class_eval do
          cattr_accessor :democracy_in_action
          after_save DemocracyInAction::Mirroring::ActiveRecord
          has_many :democracy_in_action_proxies, :as => :local, :class_name => 'DemocracyInAction::Proxy', :dependent => :destroy
        end
        require 'ostruct'
        base.democracy_in_action = OpenStruct.new({:mirrors => []})
      end

      def self.after_save(model)
        mirrors = model.class.democracy_in_action.mirrors
#        mirrors = self.democracy_in_action.mirrors #isn't this included?
        mirrors.each do |mirror|
          next unless mirror.guard.call(model) if mirror.guard
          fields = mirror.defaults(model.attributes)
          fields.merge!(mirror.mappings(model))

          proxy = model.democracy_in_action_proxies.find_or_initialize_by_remote_table(mirror.table.name)
          fields['key'] = proxy.remote_key if proxy && proxy.remote_key

          proxy.remote_key = DemocracyInAction::Mirroring.api.process mirror.table.name, fields
          proxy.save if proxy.new_record?
        end
      end
    end
  end
end
