RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_jobs_session", :secret => "4b92cb861beba0fa9d81a00f7c427cc23acf164fd9abbd2d542ea4f3352c59f830212504902ba2ab6ad082317e244f8b21c6055e541a618ec485e8f5493f2085" }
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
  end
end
