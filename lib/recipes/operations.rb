def drake(command)
  # sudo_modifier = "#{sudo :as => options[:sudo]}" if options[:sudo]
  sudo_modifier = nil
  run "cd #{current_path} && #{sudo_modifier} bundle exec rake RAILS_ENV=#{rails_env} #{command}"
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

def print_output(command)
  output = capture(command)
  puts
  puts output
  puts
end

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
    run "erb #{current_path}/config/crontab.erb > #{current_path}/config/crontab"
    sudo "cp #{current_path}/config/crontab /etc/cron.d/#{application}"
  end
  
  task(:update_custom_symlinks) do
    run <<-CMD
      rm -rf #{latest_release}/data &&
      ln -s #{shared_path}/data #{latest_release}/data
    CMD
  end
end

namespace :log do
  set :app_log_path, "/var/log/app-rabotnegi-web.log"
  
  task(:default) { app }
  task(:local) { print_log "#{current_path}/log/#{rails_env}.log" }
  task(:app) { print_log(app_log_path) }
  task(:access) { print_log "#{current_path}/log/access.log" }
  task(:error) { print_log "#{current_path}/log/error.log" }
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
  # Dumps and downloads a current copy of the server database
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
  
  # Uploads a db dump from "tmp/dump/rabotnegi_dev" to the server
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
end
