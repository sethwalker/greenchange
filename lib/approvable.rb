module Approvable
  def self.included(base)
    base.class_eval do
      acts_as_state_machine :initial => :pending
      state :pending
      state :approved, :after => :after_approved
      state :rejected
      event :approve do
        transitions :from => :pending, :to => :approved, :guard => :approval_allowed
        transitions :from => :rejected, :to => :approved
      end
      event :reject do
        transitions :from => :pending, :to => :rejected
      end
      def resolved?
        approved? || rejected?
      end
      def approval_allowed
        true
      end

      has_finder :pending, {:conditions => "state = 'pending'"}

    end
  end
end
