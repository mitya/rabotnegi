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
set :rails_env, :production
set :sudo_prompt, "xxxx"
set :bundle_without, [:development, :test]
set :shared_children, fetch(:shared_children) + %w(data)
set :public_children, []
# set :ssh_options, {keys: ["ENV['HOME']/.ssh/id_rsa"]}

set :project, "rabotnegi"
set :application, "rabotnegi"
set :domain, "rabotnegi.ru"
set :host, "www.rabotnegi.ru" # '178.79.171.92'
set :deploy_to, "/app/#{application}"
server host, :web, :app, :db, :primary => true

set :passenger_config_path, "/etc/apache2/sites-available/#{application}"
set :logrotate_config_path, "/etc/logrotate.d/#{application}"
set :nginx_config_path, "/opt/nginx/conf/sites/#{application}"
set :cron_config_path, "/etc/cron.d/#{application}"

set :default_environment, { RUBYOPT: "-Ku" }

default_run_options[:pty] = true # required for the first time repo access to answer "yes"

after "deploy:finalize_update", "deploy:update_custom_symlinks"
# external after "deploy:finalize_update", "bundle:install"
# external after "deploy:update_code", "deploy:assets:precompile"
after "deploy", "deploy:crontab"
after "deploy", "resque:restart"

task :demo do
end

__END__

mongod
redis
rsyslog
nginx + passenger
resque
cron
monit

deploy
  update
    update_code
      strategy.deploy!
      finalize_update (symlink shared log/pid/system dirs)
    symlink
  restart

cap r T=vacancies:load P="REMOTE=false"
cap crake TASK="vacancies:load REMOTE=false"

/etc/profile — rubyopt
/etc/apache2/httpd.conf
/apps/bin/ruby — rubyopt
/opt/nginx/conf/nginx.conf
/opt/nginx/conf/sites/
/var/lib/mongodb
/var/log/mongodb/mongodb.log
/etc/mongodb.conf

if $programname == 'rbg-web' then @logs.papertrailapp.com:40120
if $programname == 'popa3d' and $syslogseverity <= '6' then /var/log/popa3d.log
if $msg contains 'error' then /var/log/errlog # the expression-based way
if $syslogfacility-text == 'local0' and $msg startswith '...' and ($msg contains '...' or $msg contains '...') then ...

if $programname == 'rbg-web' then @logs.papertrailapp.com:40120
& ~
if $programname == 'rbg-web' then ~
& ~
