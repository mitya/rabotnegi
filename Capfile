load 'deploy' if respond_to?(:namespace)
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
Dir['lib/recipes/*.rb'].each { |recipe| load(recipe) }

secrets = YAML.load_file("config/secrets.yml")

set :repository,  "git@sokurenko.unfuddle.com:sokurenko/rabotnegi.git"
set :deploy_via, :remote_cache
set :scm, :git
set :user, "apprunner"
set :password, secrets["password"]
set :git_enable_submodules, true
set :keep_releases, 3
set :use_sudo, false

set :server_env, :staging # ENV['E'] == 'stg' ? :staging : :production

# case server_env when :production
#   set :rails_env, :production
#   set :host, '178.79.171.92'
#   set :application, "rabotnegi_prod"
#   set :deploy_to, "/u/rabotnegi_prod"
# when :staging
	set :rails_env, :staging
  set :host, '178.79.171.92'
  # set :ssh_options, {:keys => ["/users/dima/.ssh/id_rsa"]}
	set :application, "rabotnegi_stg"
  set :deploy_to, "/apps/rabotnegi_stg"
# when :demo
#   set :rails_env, :staging
#   set :host, "174.143.148.66"
#   # set :ssh_options, {:keys => ["/users/dima/.ssh/id_rsa"]}
#   set :application, "rabotnegi_stg"
#   set :deploy_to, "/u/rabotnegi_stg"
# end

server host, :web, :app, :db, :primary => true

# set :shared_children, fetch(:shared_children) + %w(sphinx config)
set :sudo_prompt, "xxxx-xxxx"

# set :logrotate_config, <<-end
#   #{current_path}/log/*.log {
#     daily
#     missingok
#     rotate 9
#     size 1M
#     compress
#     copytruncate
#     notifempty  
#   }
# end
# 

# task(:copy_crontab) { run "cp #{current_path}/config/crontab /etc/cron.d/#{application}" }
