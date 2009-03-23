RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_jobs_session", :secret => "4b92cb861beba0fa9d81a00f7c427cc23acf164fd9abbd2d542ea4f3352c59f830212504902ba2ab6ad082317e244f8b21c6055e541a618ec485e8f5493f2085" }
 	config.gem 'mislav-will_paginate', :version => '~> 2.3.8', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'json', :lib => 'json/add/rails'
  config.time_zone = 'Moscow'
  config.action_controller.cache_store = :file_store, "tmp/cache"

  config.after_initialize do
    require 'forwardable'
    Dir["#{Rails.root}/lib/ext/**/*.rb"].each { |file| require file }
    require 'common'
    require 'forms'
    require 'log_helper'
    
    HoptoadNotifier.configure do |config|
      config.api_key = '8b0496b81118139d93e5be18b130a7a8'
    end
    
    ADMIN_LOGIN = 'admin'
    ADMIN_PASSWORD = '0000'
    
    DB = ActiveRecord::Base.connection
  end
end
