load 'deploy' if respond_to?(:namespace) # cap2 differentiator

host = 'rabotnegi.ru'
# host = 'ec2-67-202-54-165.compute-1.amazonaws.com'

set :application, "jobs"
set :repository,  "svn://sokurenko.name/#{application}/trunk"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :export
set :user, "root"
set :web_user, "mongrel"


role :app, host
role :web, host
role :db,  host, :primary => true

namespace :deploy do
  desc "Restarts mongrels."
  task :restart, :roles => :app, :except => { :no_release => true } do 
    run "mongrel_cluster_ctl restart"
  end
end

task :after_update_code, :roles => :app do
  run "chown -R #{web_user}:#{web_user} #{release_path}"
end