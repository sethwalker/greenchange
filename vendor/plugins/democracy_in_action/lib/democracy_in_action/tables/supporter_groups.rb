module DemocracyInAction
  module Tables
    class SupporterGroups
      include DemocracyInAction::Tables::Attributes
      @@columns = [
        "supporter_groups_KEY",
        "organization_KEY",
        "supporter_KEY",
        "groups_KEY",
        "Last_Modified",
        "Properties"
      ]
    end
  end
end
