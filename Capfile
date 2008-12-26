load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
Dir['lib/recipes/*.rb'].each { |recipe| load(recipe) }

set :repository,  "git@sokurenko.unfuddle.com:sokurenko/rabotnegi.git"
set :deploy_via, :remote_cache
set :scm, :git
set :user, "root"
set :runner, "mongrel"
set :git_enable_submodules, true
set :keep_releases, 3

set :rails_env, case ENV['E']
  when 'prod': :production
  when 'stg' : :staging
  else :production
end

case rails_env
when :production
  set :host, 'rabotnegi.ru'
  set :application, "rabotnegi_prod"
  set :deploy_to, "/var/www/rabotnegi_prod"
when :staging
  set :host, 'rabotnegi.sokurenko.name'
  set :application, "rabotnegi_stg"
  set :deploy_to, "/var/www/rabotnegi_stg"
end

server host, :web, :app, :db, :primary => true 

task(:log) { puts capture("tail -n #{ENV['N'] || 200} #{current_path}/log/#{rails_env}.log") }
task(:rake) { run "cd #{current_path} && RAILS_ENV=#{rails_env} rake #{ENV['T']}" }

namespace :deploy do
  task(:copy_crontab) { run "cp #{current_path}/config/crontab /etc/cron.d/rabotnegi" }
  task(:fix_permissions) { run "chown -R #{runner}:#{runner} #{shared_path}/log #{shared_path}/pids" }
  task(:restart) { stop; start }
end

after('deploy:setup', 'deploy:fix_permissions')
after('deploy:migrate', 'deploy:fix_permissions')
