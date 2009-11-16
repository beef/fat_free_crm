set :deploy_to, "/var/www/fat_free/staging"
set :rails_env, "staging"

namespace :db do
  desc "Clear the Production DB"
  task :drop, :roles => :db do
    run("cd #{deploy_to}/current; /usr/bin/rake db:drop RAILS_ENV=#{rails_env}")
  end 
end