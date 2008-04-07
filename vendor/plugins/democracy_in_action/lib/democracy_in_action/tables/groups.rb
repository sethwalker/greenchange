module DemocracyInAction
  module Tables
    class Groups
      include DemocracyInAction::Tables::Attributes
      @@columns = [
        "groups_KEY",
        "organization_KEY",
        "chapter_KEY",
        "Group_Name",
        "parent_KEY",
        "Description",
        "Notes",
        "Display_To_User",
        "Listserve_Type",
        "Subscription_Type",
        "Manager",
        "Moderator_Emails",
        "Subject_Prefix",
        "Listserve_Responses",
        "Append_Header",
        "Append_Footer",
        "Custom_Headers",
        "Listserve_Options",
        "external_ID",
        "From_Email",
        "From_Name",
        "Reply_To",
        "Headers_To_Remove",
        "Confirmation_Message",
        "Date_Created",
        "Auto_Update",
        "query_KEY"
      ]
    end
  end
end
