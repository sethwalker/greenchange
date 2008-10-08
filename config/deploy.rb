set :application, "crabgrass"
set :repository,  "git@github.com:sethwalker/greenchange.git"

set :user, "greenchange"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/home/greenchange/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

role :app, "greenchange.slice.radicaldesigns.org"
role :web, "greenchange.slice.radicaldesigns.org"
role :db,  "greenchange.slice.radicaldesigns.org", :primary => true

set :deploy_via, :remote_cache
set :git_enable_submodules, 1

after "deploy:update_code", "deploy:symlink_shared"
after "deploy:update_code", "deploy:passenger_hates_htaccess"

namespace :deploy do

  task :start, :roles => :app do
#    invoke_command "monit -g greenchange start all", :via => run_method
  end

  task :stop, :roles => :app do
#    invoke_command "monit -g greenchange stop all", :via => run_method
  end

  task :restart, :roles => :app do
    invoke_command "touch #{release_path}/tmp/restart.txt"
#    invoke_command "monit -g greenchange restart all", :via => run_method
  end

  task :symlink_shared, :roles => :app, :except => {:no_symlink => true} do
    invoke_command "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    invoke_command "ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
    invoke_command "ln -nfs #{shared_path}/config/democracy_in_action.yml #{release_path}/config/democracy_in_action.yml"
    invoke_command "ln -nfs #{shared_path}/config/crabgrass.yml #{release_path}/config/crabgrass.yml"
    invoke_command "ln -nfs #{shared_path}/config/smtp.yml #{release_path}/config/smtp.yml"

    invoke_command "ln -nfs #{shared_path}/assets #{release_path}/assets"
    invoke_command "ln -nfs #{shared_path}/public_assets #{release_path}/public/assets"
    invoke_command "ln -nfs #{shared_path}/avatars #{release_path}/public/avatars"
    invoke_command "ln -nfs #{shared_path}/public_groups #{release_path}/public/groups"
    invoke_command "ln -nfs #{shared_path}/public_people #{release_path}/public/people"
    # avatars are now at this path
    invoke_command "ln -nfs #{shared_path}/public_uploaded #{release_path}/public/images/uploaded"

    # clear stylesheets folder
    invoke_command "rm #{release_path}/public/stylesheets/*css"
    invoke_command "ln -nfs #{shared_path}/public_stylesheets/calendar_date_select #{release_path}/public/stylesheets/calendar_date_select"
    invoke_command "ln -nfs #{shared_path}/public_stylesheets/textile-editor.css #{release_path}/public/stylesheets/textile-editor.css"
    invoke_command "rm -fr #{release_path}/db/sphinx"
    invoke_command "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
    invoke_command "chown -R nogroup #{release_path}/tmp"
    invoke_command "chmod -R g+w #{release_path}/tmp"
  end

  task :passenger_hates_htaccess, :roles => :app, :except => {:no_symlink => true} do
    invoke_command "rm #{release_path}/public/.htaccess"
  end
end

namespace :sphinx do
  desc "Generate the ThinkingSphinx configuration file"
  task :configure, :roles => :app do
    run "cd #{release_path} && rake thinking_sphinx:configure RAILS_ENV=production"
  end

  desc "Stop the sphinx server"
  task :stop, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
  end

  desc "Start the sphinx server"
  task :start, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
  end

  desc "Restart the sphinx server"
  task :restart, :roles => :app do
    stop
    start
  end  

end

after "deploy:update_code", "sphinx:configure"
before "deploy:restart", "sphinx:restart"
