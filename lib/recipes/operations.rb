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

task :script do
  run "#{current_path}/script/rails runner -e #{rails_env} #{current_path}/script/#{ENV["S"]}.rb"
end

namespace :deploy do
  task(:restart) do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task(:crontab) do
    run "erb #{current_path}/config/crontab.erb > #{current_path}/config/crontab"
    sudo "cp #{current_path}/config/crontab /etc/cron.d/#{application}"
  end
end

namespace :log do
  task(:default) { app }
  task(:app) { print_log "#{current_path}/log/#{rails_env}.log" }
  task(:web) { print_log "#{current_path}/log/access.log" }
  task(:error) { print_log "#{current_path}/log/error.log" }
  task(:dump) { print_log "#{current_path}/log/#{ENV['T']}.log" }
  
  task :f, :roles => :app do
    run("tail -f #{shared_path}/log/#{rails_env}.log") { |channel, stream, data| puts data; break if stream == :err }
  end
  
  task :pull do
    get "#{current_path}/log/production.log", "log/production.log"
  end
end

namespace :data do
  task :dump do
    database = "rabotnegi_prod"
    timestamp = Time.now.strftime("%y%m%d_%H%M")
    run "mongodump -d #{database} -o #{current_path}/tmp/db_#{timestamp}"
    run "cd #{current_path}/tmp/db_#{timestamp}/#{database} && tar cj * > #{current_path}/tmp/db.tbz"
    get "#{current_path}/tmp/db.tbz", "tmp/db_#{timestamp}.tbz"
    # system "mkdir tmp/db_#{database}_#{timestamp}"
    # system "cd tmp/db_#{database}_#{timestamp}"
    # system "tar xjf tmp/db_#{timestamp}.tbz -C tmp/db_#{database}_#{timestamp}"
  end
  
  task :restore do
    workdir = Dir.pwd
    system "cd tmp/dump/rabotnegi_demo && tar cj * > #{workdir}/tmp/localdump.tbz"
    upload "tmp/localdump.tbz", "#{current_path}/tmp/localdump.tbz"
    run "rm -rf #{current_path}/tmp/localdump"
    run "mkdir -p #{current_path}/tmp/localdump"
    run "cd #{current_path}/tmp/localdump && tar xjf #{current_path}/tmp/localdump.tbz"
    run "cd #{current_path}/tmp && mongorestore -d rabotnegi_prod --drop localdump -c vacancies"
  end
end
