task(:crake) { drake ENV["TASK"] }

task :script do
  run "#{current_path}/script/rails runner -e #{rails_env} #{current_path}/script/#{ENV["S"]}.rb"
end

task :push do
  system "git push"
  deploy.default
end

namespace :deploy do
  task(:restart) do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task(:crontab) do
    def rake(task)
      "#{user} cd $RAILS_ROOT && bundle exec rake #{task} > $RAILS_ROOT/log/cron.out 2> $RAILS_ROOT/log/cron.err"
    end

    def runner(task)
      "#{user} cd $RAILS_ROOT && script/rails runner -e $RAILS_ENV #{task} > $RAILS_ROOT/log/cron.out 2> $RAILS_ROOT/log/cron.err"
    end    
    
    config = <<-end
      MAILTO=dsokurenko@gmail.com
      PATH=$PATH:/usr/local/bin/:/usr/bin:/bin
      RUBYOPT="-Ku"
      RAILS_PROC='cron'
      RAILS_ROOT="#{current_path}"
      RAILS_ENV=#{rails_env}
  
      30 3 * * * #{ runner "RabotaRu.load" }
      0 3 * * * #{ runner "Vacancy.cleanup" }
      0 4,16 * * * #{ rake "data:dump dest=/data/backup db=rabotnegi_prod" }
      */10 * * * * #{ rake "cron:ping" }
    end
    
    put_as_root cron_config_path, config
    # run "erb #{current_path}/config/crontab.erb > #{current_path}/config/crontab"
    # sudo "cp #{current_path}/config/crontab #{cron_config_path}"  
  end
  
  task(:update_custom_symlinks) do
    run <<-CMD
      rm -rf #{latest_release}/data &&
      ln -s #{shared_path}/data #{latest_release}/data
    CMD
  end
end

namespace :log do
  set(:app_log_path) { "/data/log/#{project}.log" }
  
  task(:default) { app }
  task(:local) { print_log "#{current_path}/log/#{rails_env}.log" }
  task(:app) { print_log app_log_path }
  task(:web) { print_log "#{current_path}/log/web.log" }
  task(:error) { print_log "#{current_path}/log/web.err" }
  task(:dump) { print_log "#{current_path}/log/#{ENV['T']}.log" }
  
  task :f, :roles => :app do
    run("tail -f #{app_log_path}") { |channel, stream, data| puts data; break if stream == :err }
  end
  
  task :pull do
    get app_log_path, "log/production.log"
  end
end

namespace :backups do
  task :make do
    drake "data:dump dest=/apps/data db=rabotnegi_prod"
  end

  task :list do
    print_output "ls -l /apps/data/dump-*-*.tbz"
    print_output "df -h"
  end
  
  task :download do
    last_backup_name = capture("ls -x /apps/data/dump-*-*.tbz").split.sort.last
    get last_backup_name, "dump/#{File.basename(last_backup_name)}"
  end

  task :cleanup do
    backups = capture("ls -x /apps/data/dump-*-*.tbz").split.sort
    olds = (backups - backups.last(3)).join(" ")
    run "rm -rf #{olds}"
  end    
end

namespace :data do
  desc "dumps and downloads a current copy of the server database"
  task :dump do
    database = "rabotnegi_prod"
    timestamp = Time.now.strftime("%y%m%d_%H%M")
    run "mongodump -d #{database} -o #{current_path}/tmp/db_#{timestamp}"
    run "cd #{current_path}/tmp/db_#{timestamp}/#{database} && tar cj * > #{current_path}/tmp/db.tbz"
    get "#{current_path}/tmp/db.tbz", "dump/db_#{timestamp}.tbz"
    # system "mkdir tmp/db_#{database}_#{timestamp}"
    # system "cd tmp/db_#{database}_#{timestamp}"
    # system "tar xjf tmp/db_#{timestamp}.tbz -C tmp/db_#{database}_#{timestamp}"
  end
  
  desc "uploads a db dump from tmp/dump/rabotnegi_dev to the server"
  task :restore do
    workdir = Dir.pwd
    system "cd tmp/dump/rabotnegi_dev && tar cj * > #{workdir}/tmp/localdump.tbz"
    upload "tmp/localdump.tbz", "#{current_path}/tmp/localdump.tbz"
    run "rm -rf #{current_path}/tmp/localdump"
    run "mkdir -p #{current_path}/tmp/localdump"
    run "cd #{current_path}/tmp/localdump && tar xjf #{current_path}/tmp/localdump.tbz"
    run "cd #{current_path}/tmp && mongorestore -d rabotnegi_prod --drop localdump -c vacancies"
  end
end

namespace :redis_web do
  task(:start) { run "cd /app/redis_web && bundle exec thin -p 7010 -d start"  }
  task(:stop) { run "cd /app/redis_web && bundle exec thin -p 7010 stop"  }
end

namespace :resque_web do
  task(:start) { run "cd #{current_path} && bundle exec resque-web -p 8282 -N rabotnegi:jobs -e production"  }
  task(:stop) { run "cd #{current_path} && bundle exec resque-web -p 8282 -K"  }  
end

namespace :resque do
  task(:start) { run "RAILS_ENV=#{rails_env} #{current_path}/script/resque 1 start" }
  task(:stop) { run "RAILS_ENV=#{rails_env} #{current_path}/script/resque 1 stop" }
  task(:restart) { sudo "monit restart resque.1" }
end

namespace :monit do
  task(:status) { sudo "monit status" }
  task(:stop_all) { sudo "monit stop all" }  
end
