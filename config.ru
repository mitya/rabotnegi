# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rabotnegi::Application

# require ::File.expand_path('../config/environment',  __FILE__)
# require 'resque/server'
# 
# # Set the AUTH env variable to your basic auth password to protect Resque.
# AUTH_PASSWORD = ENV['RESQUE_PASSWORD']
# if AUTH_PASSWORD
#   Resque::Server.use Rack::Auth::Basic do |username, password|
#     password == AUTH_PASSWORD
#   end
# end
# 
# run Rack::URLMap.new(
#   "/" => Rabotnegi::Application,
#   "/resque" => Resque::Server.new 
# )
