source 'http://rubygems.org'

gem 'rails', '3.1.3'
gem 'sqlite3'
gem "bson_ext" # for mongoid
gem "mongoid"
gem 'slim'
gem 'rmagick' # for captcha
gem "galetahub-simple_captcha", :require => "simple_captcha"
gem "unicode_utils" # for cyrillic parameterization
gem "therubyracer" # weird bugs otherwise
gem "syslog-logger", :require => 'syslog_logger'

group :development, :test do
  gem 'capistrano'
  gem 'ruby-prof'
  gem 'test-unit'
  gem "factory_girl"
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'launchy'
  gem 'turn', :require => false
end

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
end
