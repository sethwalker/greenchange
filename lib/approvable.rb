module Approvable
  def self.included(base)
    base.class_eval do
      acts_as_state_machine :initial => :pending
      state :pending
      state :approved, :after => :after_approved
      state :accepted, :after => :after_accepted
      state :rejected
      state :ignored

      event :approve do
        transitions :from => :pending, :to => :approved, :guard => :approval_allowed
        transitions :from => :rejected, :to => :approved, :guard => :approval_allowed
        transitions :from => :ignored, :to => :approved, :guard => :approval_allowed
      end
      event :accept do
        transitions :from => :pending, :to => :accepted
        transitions :from => :ignored, :to => :accepted
      end
      event :reject do
        transitions :from => :pending, :to => :rejected
      end
      event :ignore do
        transitions :from => :pending, :to => :ignored
      end
      def resolved?
        approved? || rejected? || ignored?
      end
      def approval_allowed
        true
      end

      has_finder :pending, {:conditions => "state = 'pending'"}

    end
  end
end
