load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
Dir['lib/recipes/*.rb'].each { |recipe| load(recipe) }

environment = ENV['ENV'] == 'prod' ? :prod : :stg

set :repository,  "git@sokurenko.unfuddle.com:sokurenko/rabotnegi.git"
set :deploy_via, :remote_cache
set :scm, :git
set :user, "root"
set :runner, "mongrel"
set :rails_env, 'staging'

case environment
when :prod
  set :host, 'rabotnegi.ru'
  set :application, "rabotnegi_prod"
  set :deploy_to, "/var/www/rabotnegi_prod"
when :stg
  set :host, 'rabotnegi.sokurenko.name'
  set :application, "rabotnegi_stg"
  set :deploy_to, "/var/www/rabotnegi_stg"
end

role :app, host
role :web, host
role :db,  host, :primary => true

namespace :deploy do
  task :after_update_code do
    run "chown -R #{runner}:#{runner} #{release_path}"
  end
  
  task :restart do run "god restart #{application}" end  
  task :start   do run "god start   #{application}" end
  task :stop    do run "god stop    #{application}" end
end

desc "Prints server log"
task :log do
  line_count = ENV['N'] || 200
  puts capture("tail -n #{line_count} #{current_path}/log/#{rails_env}.log")
end