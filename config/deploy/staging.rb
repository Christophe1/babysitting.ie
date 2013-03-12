server "questionnarie", :app, :web, :db, :bg, :primary => true

set :user, "user"
set :password, "qwaszx@1"
set :use_sudo, false

set :branch, "staging"
set :rails_env, "staging"
set :deploy_to, "/home/user/populisto"
set :keep_releases, 5