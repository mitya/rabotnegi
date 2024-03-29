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

        error_log  #{current_path}/log/web.err notice;
        access_log #{current_path}/log/web.log combined;
        
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

    put_as_user nginx_config_path, config
    sudo "/opt/nginx/sbin/nginx -s reload"
  end
  
  task :resque_web do
    app_path = "#{shared_path}/bundle/ruby/1.9.1/gems/resque-1.19.0/lib/resque/server/public"
    config_path = "/opt/nginx/conf/sites/#{application}_resque"

    config = <<-end
      upstream resque_web {
        server 127.0.0.1:8282;
      }
    
      server {
        listen 80;
        server_name resque.admin.#{domain};

        location / {
          proxy_set_header  Host             $http_host;
          proxy_set_header  X-Real-IP        $remote_addr;
          proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
          proxy_redirect    off;
          proxy_pass        http://resque_web;
          
          auth_basic            "Restricted";
          auth_basic_user_file  htpasswd;
        }

        error_log  #{current_path}/log/resque_web.err notice;
        access_log #{current_path}/log/resque_web.log combined;
      }
    end

    put_as_user config_path, config
    sudo "/opt/nginx/sbin/nginx -s reload"
  end

  task :redis_web do
    app = "redis_web"
    app_path = "/app/#{app}"
    config_path = "/opt/nginx/conf/sites/#{app}_resque"
    port = 7010
    subdomain = "redis"
  
    config = <<-end
      upstream #{app} {
        server 127.0.0.1:#{port};
      }
    
      server {
        listen 80;
        server_name #{subdomain}.admin.#{domain};
  
        location / {
          proxy_set_header  Host             $http_host;
          proxy_set_header  X-Real-IP        $remote_addr;
          proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
          proxy_redirect    off;
          proxy_pass        http://#{app};
  
          auth_basic            "Restricted";
          auth_basic_user_file  htpasswd;          
        }
  
        error_log  #{app_path}/log/web.err notice;
        access_log #{app_path}/log/web.log combined;
      }
    end
  
    put_as_user config_path, config
    sudo "/opt/nginx/sbin/nginx -s reload"
  end  
  
  task :apache do
    domain = host.sub('www.', '')
    config = <<-end
      <VirtualHost *:80>
        ServerName #{host}
        DocumentRoot #{current_path}/public
        RailsEnv #{rails_env}
        ErrorLog  #{current_path}/log/web.err
        CustomLog #{current_path}/log/web.log combined
        
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
      #{current_path}/log/*.{log,err,out,output} {
        daily
        missingok
        rotate 7
        size 1M
        compress
        copytruncate
        notifempty  
      }
    end

    put logrotate_config_path, config
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
      number = 1

      env = "RAILS_ENV=#{rails_env} PATH=/usr/local/bin:/usr/bin:/bin:$PATH RAILS_ROOT=#{current_path}"

      config = <<-end
check process resque.#{number}
with pidfile #{current_path}/tmp/pids/resque.#{number}.pid
start program = "/usr/bin/env #{env} sh -l -c '$RAILS_ROOT/script/resque #{number} start > $RAILS_ROOT/log/resque.#{number}.output 2>&1'" as uid #{user} and gid #{user}
stop program = "/usr/bin/env #{env} sh -l -c '$RAILS_ROOT/script/resque #{number} stop > $RAILS_ROOT/log/resque.#{number}.output 2>&1'" as uid #{user} and gid #{user}
if totalmem is greater than 100 MB for 10 cycles then restart
group resque
      end
      
      put_as_user "/etc/monit/conf.d/resque", config
      sudo "monit reload"      
    end
  end
end
