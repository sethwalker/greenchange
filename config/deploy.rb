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

set :branch, "origin/master"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

after "deploy:update_code", "deploy:symlink_shared"

namespace :deploy do

  task :start, :roles => :app do
    invoke_command "monit -g greenchange start all", :via => run_method
  end

  task :stop, :roles => :app do
    invoke_command "monit -g greenchange stop all", :via => run_method
  end

  task :restart, :roles => :app do
    invoke_command "monit -g greenchange restart all", :via => run_method
  end

  task :symlink_shared, :roles => :app, :except => {:no_symlink => true} do
    invoke_command "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    invoke_command "ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
    invoke_command "ln -nfs #{shared_path}/config/democracy_in_action.yml #{release_path}/config/democracy_in_action.yml"

    invoke_command "ln -nfs #{shared_path}/assets #{release_path}/assets"
    invoke_command "ln -nfs #{shared_path}/public_assets #{release_path}/public/assets"
    invoke_command "ln -nfs #{shared_path}/avatars #{release_path}/public/avatars"
  end

end
