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
set :rails_env, ENV['E'] == 'stg' ? :staging : :production
set :sudo_prompt, "xxxx-xxxx"
# set :shared_children, fetch(:shared_children) + %w(sphinx config)
# set :ssh_options, {:keys => ["/users/dima/.ssh/id_rsa"]}

case rails_env when :production
  set :host, '178.79.171.92'
  set :application, "rabotnegi_prod"
when :staging
  set :host, '178.79.171.92'
	set :application, "rabotnegi_stg"
end

set :deploy_to, "/apps/#{application}"
server host, :web, :app, :db, :primary => true

set :passenger_config_path, "/etc/apache2/sites-available/#{application}"
set :logrotate_config_path, "/etc/logrotate.d/#{application}"

after "deploy:update", "compile_javascripts"

# deploy
#   update
#     update_code
#       strategy.deploy!
#       finalize_update (symlink shared log/pid/system dirs)
#     symlink
#   restart
