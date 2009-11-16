set :stages, %w(staging production holding)
set :default_stage, "staging"

begin
  require 'capistrano/ext/multistage'
rescue LoadError
  puts 'Capistrano Extension not found'
  puts 'sudo gem install capistrano-ext'
  exit
end

set :application, "fat_free"
set :repository,  "git@github.com:beef/fat_free_crm.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :deploy_via, :remote_cache
set :scm_verbose, true

set :user, "beefadmin"
set :runner, "beefadmin"
set :use_sudo, true
set :domain, "192.168.1.15"
default_run_options[:pty] = true

role :web, domain                         # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
set :rails_env, "production"

namespace :deploy do
  namespace :passenger do
    desc "Restart Application"
    task :restart do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end

  [:restart, :start, :stop].each do |t|
    desc "Custom #{t} restart task for Passenger"
    task t, :roles => :app, :except => { :no_release => true } do
      passenger.restart 
    end
  end
  
  desc "Set up extra folders db directory"
  task :after_setup, :roles => :app do
    run "mkdir -p -m 775 #{shared_path}/production_db"
  end  

  desc "Link the db directory"
  task :after_update_code, :roles => :app do
    run "ln -nfs #{shared_path}/production_db #{release_path}/production_db"
  end
end