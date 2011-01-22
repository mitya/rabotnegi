# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }

Rails.backtrace_cleaner.add_silencer { |line| line =~ /passenger/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rack-mount/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rack/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /railties/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /activerecord/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /activesupport/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /actionpack/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /script\/rails/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rvm\/rubies/ }

# You can also remove all the silencers if you're trying to debug a problem that might stem from framework code.
# Rails.backtrace_cleaner.remove_silencers!
