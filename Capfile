load 'deploy' if respond_to?(:namespace)
load 'deploy/assets'
require 'bundler/capistrano'

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
set :bundle_without, [:development, :test, :test_real, :test_web]
# set :shared_children, fetch(:shared_children) + %w(sphinx config)
# set :ssh_options, {:keys => ["/users/dima/.ssh/id_rsa"]}

set :application, "rabotnegi_prod"
set :host, "www.rabotnegi.ru" # '178.79.171.92'

set :deploy_to, "/apps/#{application}"
server host, :web, :app, :db, :primary => true

set :passenger_config_path, "/etc/apache2/sites-available/#{application}"
set :logrotate_config_path, "/etc/logrotate.d/#{application}"
set :nginx_config_path, "/opt/nginx/conf/sites/#{application}"

after "deploy", "deploy:crontab"
after "deploy:update_code", "deploy:update_custom_symlinks"
before "deploy:assets:precompile", "bundle:install"

# deploy
#   update
#     update_code
#       strategy.deploy!
#       finalize_update (symlink shared log/pid/system dirs)
#     symlink
#   restart

# cap r T=vacancies:load P="REMOTE=false"
