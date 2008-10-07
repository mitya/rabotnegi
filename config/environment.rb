RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_jobs_session", :secret => "REDACTED" }
  config.gem 'will_paginate'
  config.gem 'json', :lib => 'json/add/rails'
  config.time_zone = 'Moscow'

  config.after_initialize do
    require 'forwardable'
    Dir["#{Rails.root}/lib/ext/**/*.rb"].each { |file| require file }
    require 'common'
    require 'forms'
    require 'log_helper'
    require 'locale/ru-RU'
    
    HoptoadNotifier.configure do |config|
      config.api_key = 'd63821f1a3a191615790181db26aa35b'
    end
  end
end
