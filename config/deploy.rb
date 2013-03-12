require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :stages, %w(staging)
set :default_stage, "staging"

set :application, "Questionnaire Site"

set :scm, :git
set :repository,  "git@git.itransition.corp:questionnaire-site/questionnaire-site.git"
set :deploy_via, :remote_cache

set :bundle_without, [:development]

default_run_options[:pty] = true

desc "Symlink configs."
task :link_configs do
  %w(database oauth resque omnicontacts linkedin resque_schedule).each do |config_name|
    run "ln -nfs #{release_path}/config/configs/#{config_name}.yml #{release_path}/config/#{config_name}.yml"
  end
end

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :workers do
  desc "Restart daemon workers"
  task "restart", :roles => :bg do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake workers:stop"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake workers:start"
  end

  desc "Start daemon workers"
  task "start", :roles => :bg do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake workers:start"
  end

  desc "Stop daemon workers"
  task "stop", :roles => :bg do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake workers:stop"
  end
end

namespace :scheduler do
  desc "Restart resque scheduler"
  task :restart, :roles => :bg do
    stop
    start
  end

  desc "Start resque scheduler"
  task :start, :roles => :bg do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake scheduler:start"
  end

  desc "Stop resque scheduler"
  task :stop, :roles => :bg do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake scheduler:stop"
  end
end

after "deploy:finalize_update", :link_configs
after "deploy:create_symlink", "workers:restart", "scheduler:restart"
after "deploy:rollback", "workers:restart", "scheduler:restart"