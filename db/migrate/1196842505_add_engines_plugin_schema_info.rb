class AddEnginesPluginSchemaInfo < ActiveRecord::Migration
  def self.up
    #enhanced migrations style
    connection = ActiveRecord::Base.connection
    execute <<-ESQL
        CREATE TABLE #{Engines::PluginMigrator.schema_info_table_name} 
          (id #{connection.type_to_sql(:integer)}, created_at #{connection.type_to_sql(:datetime)}, plugin_name #{connection.type_to_sql(:string)}, PRIMARY KEY (id))
      ESQL
  end

  def self.down
    drop_table Engines::PluginMigrator.schema_info_table_name
  end
end
