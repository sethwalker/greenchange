class DemocracyInActionMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'install_democracy_in_action.rb', 'db/migrate', :migration_file_name => 'install_democracy_in_action.rb'
    end
  end
end
