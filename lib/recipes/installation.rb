default_run_options[:pty] = true # required for the first time repo access to answer "yes"

def run_rake(task, params = "", options = {})
  sudo_modifier = "#{sudo :as => options[:sudo]}" if options[:sudo]
  run "cd #{current_path} && #{sudo_modifier} RAILS_ENV=#{rails_env} rake #{task} #{params}"
end

# namespace :deploy do
#   task(:start)   { }  
#   task(:stop)    { }
#   task(:restart) { run "touch #{current_path}/tmp/restart.txt" }
# end

# task(:log) { puts capture("tail -n #{ENV['N'] || 200} #{current_path}/log/#{rails_env}.log") }
# task(:rake) { run_rake ENV['T'], ENV['P'] }
# task(:rake_as_runner) { run_rake ENV['T'], ENV['P'], :sudo => runner }
# task(:fix_permissions) { run "chown -R #{runner}:#{runner} #{current_path}/ #{shared_path}/log #{shared_path}/pids" }

# after 'deploy:migrate', 'fix_permissions'
# after 'deploy:update', 'fix_permissions'
# 
namespace :deploy do
  namespace :install do
    task :default do
      setup
      git
      gems
      # update
      # db
      # migrate
      # passenger
      # logrotate
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

    task :db do
      run_rake "db:create"
    end
    
    # task :logrotate do
    #   put logrotate_config, "/etc/logrotate.d/#{application}" 
    # end
    # 
    # task :passenger do
    #   put passenger_config, "/etc/apache2/sites-available/#{application}"
    #   sudo "a2ensite #{application}"
    #   sudo "/etc/init.d/apache2 reload"
    # end
    # 
    # def append_text(text, file)
    #   # text = text.gsub("'", "'\\\\''").gsub("\n", '\n')
    #   # run "echo -e '#{text}' | tee -a #{file}"
    #   # run "tee -a #{file}", :data => text
    #   # run "cat >> #{file}", :data => text
    #   ("\n" + text + "\n").each_line { |line| run %(echo "#{line}" >> #{file}) }
    # end
  end
end
# 
# before "deploy:setup" do
#   sudo "mkdir -p /apps"
# end
