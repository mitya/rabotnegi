RAILS_GEM_VERSION = '2.1' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_jobs_session", :secret => "REDACTED" }

  config.gem 'will_paginate'
  
  config.after_initialize do
    require 'forwardable'
    Dir["#{Rails.root}/lib/ext/**/*.rb"].each { |file| require file }
    require 'common'
    require 'forms'
    require 'log_helper'
  end
end