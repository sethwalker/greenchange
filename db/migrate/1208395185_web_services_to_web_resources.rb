class WebServicesToWebResources < ActiveRecord::Migration
  def self.up
    rename_table :web_services, :web_resources
    rename_column :web_resources, :web_service_handle, :web_resource
    rename_column :web_resources, :web_service_type, :web_resource_type
  end

  def self.down
    rename_column :web_resources, :web_resource_type, :web_service_type
    rename_column :web_resources, :web_resource, :web_service_handle
    rename_table :web_resources, :web_services
  end
end
