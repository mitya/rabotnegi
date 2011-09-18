Rails.backtrace_cleaner.add_silencer { |line| line =~ /passenger/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rack-mount/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rack/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /railties/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /activerecord/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /activesupport/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /actionpack/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /script\/rails/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rvm\/rubies/ }

Rails.backtrace_cleaner.remove_silencers!
