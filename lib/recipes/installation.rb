default_run_options[:pty] = true # required for the first time repo access to answer "yes"

namespace :install do
  task :default do
    deploy.setup
    git

    deploy.update
    gems
    mysql
    deploy.migrate
    nginx
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
    drake "db:create"
  end

  task :nginx do
    config = <<-end
      server {
        listen 80;
        server_name #{domain};
        root #{current_path}/public;
        passenger_enabled on;
        passenger_min_instances 1;
        rails_env #{rails_env};

        log_format asset '$remote_addr [$time_local] "$request" $status $body_bytes_sent';

        error_log  #{current_path}/log/error.log notice;
        access_log #{current_path}/log/access.log combined;
        
        gzip             on;
        gzip_types       text/plain text/css text/javascript application/xml application/javascript application/x-javascript;
        gzip_min_length  512;
        gzip_disable     "msie6";
        
        location ~ ^/(assets)/ {
          gzip_static on;
          expires 1y;
          add_header Cache-Control public;
          access_log #{current_path}/log/asset.log asset;
        }
      }
      
      server {
        server_name www.#{domain};
        rewrite ^ $scheme://#{domain}$uri permanent;
      }
      
      passenger_pre_start http://#{domain};
    end

    sudo "touch #{nginx_config_path}"
    sudo "chown #{user}:#{user} #{nginx_config_path}"
    put config, nginx_config_path
    sudo "/opt/nginx/sbin/nginx -s reload"
  end
  
  task :apache do
    domain = host.sub('www.', '')
    config = <<-end
      <VirtualHost *:80>
        ServerName #{host}
        DocumentRoot #{current_path}/public
        RailsEnv #{rails_env}
        ErrorLog  #{current_path}/log/error.log
        CustomLog #{current_path}/log/access.log combined
        
        <Location /assets/>
          Header unset Last-Modified
          Header unset ETag
          FileETag None
          ExpiresActive On
          ExpiresDefault "access plus 1 year"
        
          # precompress gz files
          # 2 lines to serve pre-gzipped version
          RewriteCond %{REQUEST_FILENAME}.gz -s
          RewriteRule ^(.+) $1.gz [L]
        </Location>
      </VirtualHost>      

      <VirtualHost *:80>
        ServerName #{domain}
        ServerAlias *.#{domain}
        RewriteEngine On
        RewriteRule ^/(.*)$ http://#{host}/$1 [R=301,L]
      </VirtualHost>      
    end

    sudo "touch #{passenger_config_path}"
    sudo "chown #{user}:#{user} #{passenger_config_path}"
    put config, passenger_config_path
    sudo "a2enmod rewrite headers expires"
    sudo "a2ensite #{application}"
    sudo "/etc/init.d/apache2 reload"
    
    # sudo "a2dissite #{application}"
    # sudo "/etc/init.d/apache2 reload"    
  end

  task :logrotate do
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

    sudo "touch #{logrotate_config_path}"
    sudo "chown #{user}:#{user} #{path}"
    put config, logrotate_config_path
  end  
  
  task :undo do
    drake "db:drop"
    sudo "rm -rf #{deploy_to}"
    sudo "rm -rf #{nginx_config_path}"
    sudo "rm -rf #{logrotate_config_path}"
    sudo "/opt/nginx/sbin/nginx -s reload"
  end
  
  namespace :monit do
    task :resque do
      name = "resque_main"
      env = "HOME=/home/#{runner} RACK_ENV=#{rails_env} PATH=/usr/local/bin:/usr/local/ruby/bin:/usr/bin:/bin:$PATH"
      rake_env = "RAILS_ENV=#{rails_env} QUEUE=#{queue} VERBOSE=1 PIDFILE=tmp/pids/#{name}.pid"
      queue = "main"
      config = <<-end
        check process name
        with pidfile #{current_path}/tmp/pids/name.pid
        start program = "/usr/bin/env #{env} /bin/sh -l -c 'cd #{current_path}; nohup bundle exec rake resque:work #{rake_env} & >> log/#{name}.log 2>&1'" as uid #{runner} and gid #{runner}
        stop program = "/bin/sh -c 'cd #{current_path} && kill -9 %(cat tmp/pids/#{name}.pid) && rm -f tmp/pids/#{name}.pid; exit 0;'"
        if totalmem is greater than 200 MB for 10 cycles then restart
        group resque
      end
      
      put config, "/etc/monit.d/#{name}"
    end
  end
end
