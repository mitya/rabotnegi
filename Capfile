load 'deploy' if respond_to?(:namespace)
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
Dir['lib/recipes/*.rb'].each { |recipe| load(recipe) }

set :repository,  "git@sokurenko.unfuddle.com:sokurenko/rabotnegi.git"
set :deploy_via, :remote_cache
set :scm, :git
set :user, "root"
set :runner, "www-data"
set :git_enable_submodules, true
set :keep_releases, 3

set :server_env, :demo # ENV['E'] == 'stg' ? :staging : :production

case server_env when :production
	set :rails_env, :production
  set :host, 'rabotnegi.ru'
  set :application, "rabotnegi_prod"
  set :deploy_to, "/u/rabotnegi_prod"
when :staging
	set :rails_env, :staging
  set :host, 'rabotnegi.sokurenko.name'
	set :ssh_options, {:keys => ["/users/dima/.ssh/id_main"]}
	set :application, "rabotnegi_stg"
  set :deploy_to, "/u/rabotnegi_stg"
when :demo
	set :rails_env, :staging
  set :host, 'ec2-174-129-45-5.compute-1.amazonaws.com'
	set :ssh_options, {:keys => ["/users/dima/.ssh/id_demo"]}
	set :application, "rabotnegi_stg"
  set :deploy_to, "/u/rabotnegi_stg"
end

server host, :web, :app, :db, :primary => true

set :shared_children, fetch(:shared_children) + %w(sphinx config)
set :local_git_key_path, "/users/dima/.ssh/id_unfuddle"
set :git_key_path, "/root/.ssh/id_unfuddle"
set :git_host_alias, "sokurenko.unfuddle.com"
set :git_host_name, "sokurenko.unfuddle.com"

set :ssh_config, <<-end
  Host #{git_host_alias}
  User git
  Hostname #{git_host_name}
  IdentityFile #{git_key_path}
end

set :logrotate_config, <<-end
  #{current_path}/log/*.log {
    daily
    missingok
    rotate 9
    size 1M
    compress
    copytruncate
    notifempty	
  }
end

set :passenger_config, <<-end
  <VirtualHost *:80>
    ServerName #{host}
    DocumentRoot #{current_path}/public
    RailsEnv #{rails_env}
    ErrorLog  #{current_path}/log/error.log
    CustomLog #{current_path}/log/access.log common
  </VirtualHost>
end

task(:copy_crontab) { run "cp #{current_path}/config/crontab /etc/cron.d/#{application}" }
