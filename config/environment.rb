RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_resource ]
  config.active_record.schema_format = :sql
  config.active_record.colorize_logging = false
  config.action_controller.session = { :session_key => "_jobs_session", :secret => "fa9a001aca32f22c4986e046fcb044234e6187b89fe66818774e2cac" }
end

require 'models/init'