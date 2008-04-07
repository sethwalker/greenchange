require File.join(File.dirname(__FILE__), '..', 'vendor', 'democracy_in_action', 'lib', 'democracyinaction.rb')

module DemocracyInAction
  class << self
    def configure(&block)
      instance_eval(&block) if block_given?
    end

    def auth
      DemocracyInAction::Auth
    end

    def mirror(table=nil, model=nil, &block)
      #mirror(:groups, Group) {|g| g.parent_KEY = 1234}
      DemocracyInAction::Mirroring.mirror(table, model, &block)

      #mirror.supporter = User
        #mirror(User => 'supporter')
#      else
#        DemocracyInAction::Mirroring
#      end
    end
  end
end
