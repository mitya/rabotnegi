default_run_options[:pty] = true # required for the first time repo access to answer "yes"

def run_rake(task, params = "", options = {})
  sudo_modifier = "#{sudo :as => options[:sudo]}" if options[:sudo]
  run "cd #{current_path} && #{sudo_modifier} RAILS_ENV=#{rails_env} rake #{task} #{params}"
end

# def append_text(text, file)
#   # text = text.gsub("'", "'\\\\''").gsub("\n", '\n')
#   # run "echo -e '#{text}' | tee -a #{file}"
#   # run "tee -a #{file}", :data => text
#   # run "cat >> #{file}", :data => text
#   ("\n" + text + "\n").each_line { |line| run %(echo "#{line}" >> #{file}) }
# end

def print_log(path)
  puts capture("tail -n #{ENV['N'] || 200} #{path}")
end

task(:r) { run_rake ENV['T'], ENV['P'] }

# task(:fix_permissions) { run "chown -R #{runner}:#{runner} #{current_path}/ #{shared_path}/log #{shared_path}/pids" }
# task(:copy_crontab) { run "cp #{current_path}/config/crontab /etc/cron.d/#{application}" }
task(:compile_javascripts) { run_rake "barista:brew" }

namespace :deploy do
  task(:restart) { run "touch #{current_path}/tmp/restart.txt" }
end

namespace :log do
  task(:default) { app }
  task(:app) { print_log "#{current_path}/log/#{rails_env}.log" }
  task(:access) { print_log "#{current_path}/log/access.log" }
  task(:error) { print_log "#{current_path}/log/error.log" }
end

namespace :install do
  task :default do
    deploy.setup
    git
    gems

    deploy.update
    mysql
    deploy.migrate
    passenger
    logrotate
  end

  task :git do
    git_host = "sokurenko.unfuddle.com"
    git_key_path = "/home/#{user}/.ssh/id_git_#{application}"
    ssh_config_path = "/home/#{user}/.ssh/config"
    
    top.upload "/users/dima/.ssh/id_unfuddle", git_key_path, :mode => "600"
    run "touch #{ssh_config_path}"
    run "chmod 600 #{ssh_config_path}"

    ssh_config = <<-end
      Host #{git_host}
      User git
      Hostname #{git_host}
      IdentityFile #{git_key_path}
    end

    entry_delimiter = "## config for #{git_host}"
    entry = entry_delimiter + "\n" + ssh_config + entry_delimiter + "\n"
    
    current_config = capture "cat #{ssh_config_path}"
    current_config.gsub! /(\n|\r)+/, "\n" # there is a bunch of "\r" here
    current_config.gsub! /^#{entry_delimiter}$.*^#{entry_delimiter}$/m, ''
        
    put current_config + entry, ssh_config_path
  end

  task :gems do
    run "cd #{current_path} && #{sudo} bundle"
  end

  task :mysql do
    run_rake "db:create"
  end
  
  task :passenger do
    path = "/etc/apache2/sites-available/#{application}"
    config = <<-end
      <VirtualHost *:80>
        ServerName #{host}
        DocumentRoot #{current_path}/public
        RailsEnv #{rails_env}
        ErrorLog  #{current_path}/log/error.log
        CustomLog #{current_path}/log/access.log common
      </VirtualHost>
    end

    sudo "touch #{path}"
    sudo "chown #{user}:#{user} #{path}"
    put config, path
    sudo "a2ensite #{application}"
    sudo "/etc/init.d/apache2 reload"
  end

  task :logrotate do
    path = "/etc/logrotate.d/#{application}"
    config = <<-end
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

    sudo "touch #{path}"
    sudo "chown #{user}:#{user} #{path}"
    put config, path
  end  
end
