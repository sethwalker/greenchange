module DemocracyInAction
  class Proxy < ActiveRecord::Base
    set_table_name :democracy_in_action_proxies
    belongs_to :local, :polymorphic => true

    def before_destroy
      DemocracyInAction::Mirroring.api.delete self.remote_table, {'key' => self.remote_key}
    end
  end
end
