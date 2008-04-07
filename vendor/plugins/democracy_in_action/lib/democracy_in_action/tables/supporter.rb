module DemocracyInAction
  module Tables
    class Supporter
      include DemocracyInAction::Tables::Attributes

      #override cattr_accessor
      def columns
        @@columns - @@protected
      end

      @@protected = [
        "Password"
      ]

      @@columns = [
        "supporter_KEY",
        "organization_KEY",
        "chapter_KEY",
        "Last_Modified",
        "Date_Created",
        "Title",
        "First_Name",
        "MI",
        "Last_Name",
        "Suffix",
        "Email",
        "Password",
        "Receive_Email",
        "Email_Status",
        "Email_Preference",
        "Soft_Bounce_Count",
        "Hard_Bounce_Count",
        "Last_Bounce",
        "Receive_Phone_Blasts",
        "Phone",
        "Cell_Phone",
        "Phone_Provider",
        "Work_Phone",
        "Pager",
        "Home_Fax",
        "Work_Fax",
        "Street",
        "Street_2",
        "Street_3",
        "City",
        "State",
        "Zip",
        "PRIVATE_Zip_Plus_4",
        "County",
        "District",
        "Country",
        "Latitude",
        "Longitude",
        "Organization",
        "Department",
        "Occupation",
        "Instant_Messenger_Service",
        "Instant_Messenger_Name",
        "Web_Page",
        "Alternative_Email",
        "Other_Data_1",
        "Other_Data_2",
        "Other_Data_3",
        "Notes",
        "Source",
        "Source_Details",
        "Source_Tracking_Code",
        "Tracking_Code",
        "Status",
        "uid",
        "Timezone"
      ]
    end
  end
end
