module DemocracyInAction
  module Tables
    class SupporterEvent
      include DemocracyInAction::Tables::Attributes
      @@columns = [
        "supporter_event_KEY",
        "organization_KEY",
        "supporter_KEY",
        "event_KEY",
        "donation_KEY",
        "Last_Modified",
        "Date_Created",
        "_Type",
        "_Status",
        "Additional_Attendees"
      ]
    end
  end
end
