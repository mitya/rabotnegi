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
  lines = ENV['N'] || 200
  query = ENV['Q']

  if query
    command = "cat #{path} | grep #{query} | tail -n #{lines}"
  else
    command = "tail -n #{lines} #{path}"
  end

  puts capture(command, via: :sudo)
end

def print_output(command)
  output = capture(command)
  puts
  puts output
  puts
end

def put_as_user(path, config)
  sudo "touch #{path}"
  sudo "chown #{user}:#{user} #{path}"
  put config, path  
end

def put_as_root(path, config)
  put_as_user(path, config)
  sudo "chown root:root #{path}"
end
